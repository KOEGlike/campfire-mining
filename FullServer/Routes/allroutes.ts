import { Router } from "express";
import { CreateUser, GetRegister } from "../Controllers/Register";
import { CreateFullScore, GetFullScore } from "../Controllers/Scoreboard";

const router = Router();

router.post("/createuser", CreateUser);
router.get("/getusers", GetRegister);
router.post("/createscore", CreateFullScore);
router.get("/getfullscore", GetFullScore);

export { router };
