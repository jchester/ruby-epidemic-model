-------------------------------------------
-- Developed by Jacques Chester 20304893 --
-------------------------------------------

-- SQLite schema for storing data.
-- Note that started/stopped fields use TEXT type; SQLite does not support DATETIME fields.

create table if not exists tick (
    tick_id                     integer primary key,
    epidemic_id                 integer constraint fk_tick_epidemic references epidemic(epidemic_id),
    time                        integer,
    healthy                     integer,
    sick                        integer,
    immunised                   integer,
    dead                        integer
);

create table if not exists epidemic (
    epidemic_id                 integer primary key,
   	run_id                      integer constraint fk_epidemic_run references run(run_id),
    started                     text,
    stopped                     text,
    population                  integer,
    infection_density           real,
    recovery_probability        real,
    infection_probability       real,
	immunised_density			real
);

create table if not exists run (
    run_id                      integer primary key,
    started                     text,
    stopped                     text,
    neighbourhood_type          text,
    max_population              integer,
    min_population              integer,
    max_infection_density       real,
    min_infection_density       real,
    max_recovery_probability    real,
    min_recovery_probability    real,
    max_infection_probability   real,
    min_infection_probability   real,
	max_immunised_density		real,
	min_immunised_density		real
);