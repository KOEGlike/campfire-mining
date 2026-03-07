CREATE TABLE "Scoreboard" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" integer NOT NULL,
	"completed_time" time NOT NULL,
	"starcount" integer,
	"score" integer,
	"iscompleted" boolean DEFAULT false NOT NULL,
	CONSTRAINT "Scoreboard_user_id_unique" UNIQUE("user_id")
);
--> statement-breakpoint
CREATE TABLE "users" (
	"id" serial PRIMARY KEY NOT NULL,
	"live" integer DEFAULT 3 NOT NULL,
	"name" varchar(15) NOT NULL
);
--> statement-breakpoint
ALTER TABLE "Scoreboard" ADD CONSTRAINT "Scoreboard_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;