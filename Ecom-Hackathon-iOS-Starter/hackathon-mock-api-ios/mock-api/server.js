const express = require("express");
const fs = require("fs");
const path = require("path");
const http = require("http");
const { Server } = require("socket.io");
const cors = require("cors");

const app = express();
const PORT = 3001;

app.use(cors());
app.use(express.json());

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

// Serve image files from the local "images" directory
app.use("/images", express.static(path.join(__dirname, "images")));

function readJson(fileName) {
  const filePath = path.join(__dirname, "responses", fileName);
  if (!fs.existsSync(filePath)) return {};
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function delayedJson(res, fileName, status = 200, delay = 500) {
  setTimeout(() => {
    res.status(status).json(readJson(fileName));
  }, delay);
}

app.get("/health", (req, res) => {
  res.json({ status: "ok", socketEnabled: true });
});

app.post("/login", (req, res) => {
  const { email, password } = req.body || {};
  if (email === "demo@hackathon.com" && password === "123456") {
    return delayedJson(res, "login_success.json", 200, 400);
  }
  return delayedJson(res, "error_401.json", 401, 400);
});

app.get("/profile", (req, res) => {
  return delayedJson(res, "profile.json", 200, 600);
});

app.get("/feed", (req, res) => {
  return delayedJson(res, "feed.json", 200, 700);
});

app.get("/skus", (req, res) => {
  return delayedJson(res, "skus.json", 200, 700);
});

// Collaborative Cart Data
const carts = {};

io.on("connection", (socket) => {
  console.log("A user connected:", socket.id);

  socket.on("create-cart", (cartId) => {
    socket.join(cartId);
    if (!carts[cartId]) {
      carts[cartId] = { items: [], members: [] };
      console.log(`Cart ${cartId} created by ${socket.id}`);
    }
    
    // Add creator as member
    if (!carts[cartId].members.find(m => m.id === socket.id)) {
      const member = { 
        id: socket.id, 
        name: "User " + socket.id.substr(0, 4), 
        avatar: `https://i.pravatar.cc/150?u=${socket.id}` 
      };
      carts[cartId].members.push(member);
    }
    
    io.to(cartId).emit("cart-updated", carts[cartId]);
  });

  socket.on("join-cart", (cartId) => {
    if (!carts[cartId]) {
      socket.emit("error", { message: "Cart not found. Please check the code." });
      console.log(`User ${socket.id} tried to join non-existent cart ${cartId}`);
      return;
    }

    socket.join(cartId);
    
    // Add member
    if (!carts[cartId].members.find(m => m.id === socket.id)) {
      const member = { 
        id: socket.id, 
        name: "User " + socket.id.substr(0, 4), 
        avatar: `https://i.pravatar.cc/150?u=${socket.id}` 
      };
      carts[cartId].members.push(member);
    }
    
    io.to(cartId).emit("cart-updated", carts[cartId]);
    console.log(`User ${socket.id} joined cart ${cartId}`);
  });

  socket.on("leave-cart", (cartId) => {
    socket.leave(cartId);
    if (carts[cartId]) {
      carts[cartId].members = carts[cartId].members.filter(m => m.id !== socket.id);
      if (carts[cartId].members.length === 0) {
        delete carts[cartId];
        console.log(`Cart ${cartId} deleted as last member left`);
      } else {
        io.to(cartId).emit("cart-updated", carts[cartId]);
      }
    }
    console.log(`User ${socket.id} left cart ${cartId}`);
  });

  socket.on("add-item", ({ cartId, item }) => {
    if (carts[cartId]) {
      const existingItem = carts[cartId].items.find(i => i.id === item.id);
      if (existingItem) {
        existingItem.quantity = (existingItem.quantity || 1) + (item.quantity || 1);
      } else {
        const member = carts[cartId].members.find(m => m.id === socket.id);
        carts[cartId].items.push({ 
          ...item, 
          quantity: item.quantity || 1,
          reactions: {}, 
          comments: [],
          addedBy: member ? member.name : "Guest"
        });
      }
      io.to(cartId).emit("cart-updated", carts[cartId]);
    }
  });

  socket.on("remove-item", ({ cartId, itemId }) => {
    if (carts[cartId]) {
      carts[cartId].items = carts[cartId].items.filter(i => i.id !== itemId);
      io.to(cartId).emit("cart-updated", carts[cartId]);
    }
  });

  socket.on("update-quantity", ({ cartId, itemId, change }) => {
    if (carts[cartId]) {
      const item = carts[cartId].items.find(i => i.id === itemId);
      if (item) {
        item.quantity = Math.max(1, (item.quantity || 1) + change);
        io.to(cartId).emit("cart-updated", carts[cartId]);
      }
    }
  });

  socket.on("add-reaction", ({ cartId, itemId, emoji }) => {
    if (carts[cartId]) {
      const item = carts[cartId].items.find(i => i.id === itemId);
      if (item) {
        if (!item.userReactions) item.userReactions = {};
        
        let removedCurrentEmoji = false;

        // Iterate through all emojis to remove any previous reaction by this user
        for (const e in item.userReactions) {
          const index = item.userReactions[e].indexOf(socket.id);
          if (index !== -1) {
            item.userReactions[e].splice(index, 1);
            if (e === emoji) removedCurrentEmoji = true;
          }
        }

        // If the user clicked a NEW emoji, add it.
        // If they clicked the SAME one they had, it stays removed (toggle off).
        if (!removedCurrentEmoji) {
          if (!item.userReactions[emoji]) item.userReactions[emoji] = [];
          item.userReactions[emoji].push(socket.id);
        }

        // Rebuild the reactions count map for the client
        item.reactions = {};
        for (const e in item.userReactions) {
          const count = item.userReactions[e].length;
          if (count > 0) {
            item.reactions[e] = count;
          }
        }
        
        io.to(cartId).emit("cart-updated", carts[cartId]);
      }
    }
  });

  socket.on("add-comment", ({ cartId, itemId, text }) => {
    if (carts[cartId]) {
      const item = carts[cartId].items.find(i => i.id === itemId);
      if (item) {
        item.comments.push({
          id: Date.now().toString(),
          text: text,
          userName: "User " + socket.id.substr(0, 4),
          timestamp: new Date().toISOString()
        });
        io.to(cartId).emit("cart-updated", carts[cartId]);
      }
    }
  });

  socket.on("disconnect", () => {
    for (const cartId in carts) {
      const memberIndex = carts[cartId].members.findIndex(m => m.id === socket.id);
      if (memberIndex !== -1) {
        carts[cartId].members.splice(memberIndex, 1);
        if (carts[cartId].members.length === 0) {
          delete carts[cartId];
          console.log(`Cart ${cartId} deleted after last member disconnected`);
        } else {
          io.to(cartId).emit("cart-updated", carts[cartId]);
        }
      }
    }
    console.log("User disconnected:", socket.id);
  });
});

server.listen(PORT, "0.0.0.0", () => {
  console.log(`Mock API with Socket.IO running on http://0.0.0.0:${PORT}`);
});