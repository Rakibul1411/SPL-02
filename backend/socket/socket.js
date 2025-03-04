import { Server } from "socket.io";

let io;

export const initSocket = (server) => {
  io = new Server(server, { cors: { origin: "*" } });

  io.on("connection", (socket) => {
    console.log("🔌 New gig worker connected:", socket.id);

    socket.on("disconnect", () => {
      console.log("❌ Gig worker disconnected");
    });
  });
};

// Function to send notifications to all gig workers
export const sendNotification = (message) => {
  io.emit("newTask", message); // Send notification to all connected gig workers
  console.log("Task Notification Sent!!!");
};
