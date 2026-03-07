import { pgTable, PgTable,serial,varchar,integer, boolean, time } from "drizzle-orm/pg-core";

export const User = pgTable("users",{
    id: serial("id").primaryKey(),
    allive: integer("live").notNull().default(3),
    name: varchar("name", {length: 15}).notNull(),
});

export const ScoreTable = pgTable("Scoreboard",{
    id:serial("id").primaryKey(),
    userId: integer("user_id").notNull().references(() => User.id).unique(),
    completedTime:time("completed_time").notNull(),
    starscount: integer("starcount"),
    score: integer("score"),
    iscompleted:boolean("iscompleted").notNull().default(false),
})