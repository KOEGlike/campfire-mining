import express from "express";
import cors from "cors";
import { errorHandler } from "./Middlewares/ErrorHandler";
import { router as allRoutes } from "./Routes/allroutes";

const app = express();

const allowedOrigins = [
  "https://phgjaqmakdewq.ok.kimi.link",
  "http://localhost:3000",
  "http://localhost:5173",
  "http://localhost:8060",
  "http://127.0.0.1:5173",
  "https://koeglike.itch.io",
  "https://itch.io",
];

app.use(cors({
  origin: (origin, callback) => {
    if (!origin) return callback(null, true);
    
    const isAllowed = allowedOrigins.some(allowed => 
      origin === allowed || 
      origin.startsWith("https://v6p") || 
      origin.includes("hwcdn.net") ||
      origin.includes("itch.zone")
    );
    
    if (isAllowed) {
      callback(null, true);
    } else {
      console.log("Blocked origin:", origin);
      callback(new Error("Not allowed by CORS"));
    }
  },
  credentials: true
}));

app.use(express.json());

app.use("/", allRoutes);

app.get("/test", (req, res) => {
  res.status(200).json({ message: "aaaa" });
});

app.use(errorHandler);
app.listen(5000, () => {
  console.log("server started on Port 5000");
});
