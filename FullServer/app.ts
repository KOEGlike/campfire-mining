import express from "express";
import { errorHandler } from "./Middlewares/ErrorHandler";
import { router as allRoutes } from "./Routes/allroutes";

const app = express();

app.use(express.json());

app.use("/", allRoutes);

app.get("/test", (req, res) => {
  res.status(200).json({ message: "aaaa" });
});

app.use(errorHandler);
app.listen(5000, () => {
  console.log("server started on Port 5000");
});
