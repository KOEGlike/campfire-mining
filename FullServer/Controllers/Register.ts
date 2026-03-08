import { Response, Request, NextFunction } from "express";
import { serverdb } from "../db/db";
import { User } from "./../db/schema";

export const CreateUser = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { name } = req.body;
    if (name) {
      const newUser = await serverdb.insert(User).values({ name }).returning();
      res.status(200).json({ message: "success", success: true, Data: newUser[0] });
    }
  } catch (error) {
    next(error);
  }
};

export const GetRegister = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const alluser = await serverdb.select().from(User);
    console.log(alluser)
    res.status(200).json({success:true,users:alluser})
  } catch (error) {
    next(error);
  }
};
