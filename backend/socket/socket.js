import { Server } from "socket.io";

let io;

export const initSocket = (server) => {
  io = new Server(server, { cors: { origin: "*" } });

  io.on("connection", (socket) => {
    console.log("🔌 New client connected");

    socket.on("assignTask", (task) => {
      console.log("📌 New Task Assigned:", task);
      io.emit("newTask", task); // Broadcast task to all clients
    });

    socket.on("disconnect", () => {
      console.log("❌ Client disconnected");
    });
  });
};

export { io };
