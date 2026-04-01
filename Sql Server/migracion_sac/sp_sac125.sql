--

drop procedure sp_sac125;

create procedure sp_sac125()
returning integer,
          char(50);

delete from sac:cglprepor;

-- Primas Reaseguro Cedido

insert into sac:cglprepor
values (2009,	"511",	20.25,	31.91,	30.00,	6.00,	62.22,	13.19,	50.00,	10.00,	40.00,	89.44,	79.30,	85.77);

--values (2009,	"511",	20.00,	30.00,	30.00,	6.00,	60.00,	10.00,	50.00,	10.00,	40.00,	40.00,	40.00,	40.00);

-- Primas Reaseguro Asumido

insert into sac:cglprepor
values (2009,	"412",	0.00,	0.00,	0.00,	0.00,	0.00,	0.00,	50.00,	0.00,	0.00,	0.00,	0.00,	0.00);

-- Variacion Reserva Tecnica

insert into sac:cglprepor
values (2009,	"551",	7.39,	4.67,	4.61,	2.60,	10.28,	0.92,	8.95,	12.20,	16.41,	14.34,	15.34,	14.73);

-- Siniestros Pagados

insert into sac:cglprepor
values (2009,	"541",	30.00,	30.00,	30.00,	65.00,	20.00,	50.00,	50.00,	50.00,	30.00,	30.00,	30.00,	5.00);

-- Siniestros Recuperados

insert into sac:cglprepor
values (2009,	"417",	5.00,	0.00,	0.00,	1.20,	12.00,	10.00,	0.00,	5.00,	12.00,	12.00,	12.00,	0.00);

-- Recobros

insert into sac:cglprepor
values (2009,	"419",	0.00,	0.00,	0.00,	0.00,	1.00,	20.00,	4.35,	0.00,	0.00,	0.00,	0.00,	0.00);

-- Variacion de Siniestros

insert into sac:cglprepor
values (2009,	"553",	1.77,	1.77,	1.77,	1.77,	1.77,	1.77,	1.77,	1.77,	1.77,	1.77,	1.77,	1.77);

-- Comisiones Pagadas Corredores

insert into sac:cglprepor
values (2009,	"521",	24.00,	17.50,	17.50,	10.00,	22.50,	15.00,	18.50,	16.50,	15.00,	12.50,	13.50,	4.00);

-- Comisiones Ganadas Reaseguros

insert into sac:cglprepor
values (2009,	"413",	22.11,	21.00,	20.17,	-5.00,	45.00,	30.00,	18.00,	20.00,	15.00,	20.00,	20.00,	20.00);

--values (2009,	"413",	27.11,	26.00,	25.17,	0.00,	50.00,	35.00,	23.00,	25.00,	20.00,	25.00,	25.00,	25.00);

-- Impuestos Pagados

insert into sac:cglprepor
values (2009,	"531",	2.00,	2.00,	2.00,	2.00,	2.00,	2.00,	2.00,	2.00,	2.00,	2.00,	2.00,	0.00);

-- Impuestos Recuperados

insert into sac:cglprepor
values (2009,	"422",	2.00,	2.00,	2.00,	2.00,	2.00,	2.00,	2.00,	2.00,	2.00,	2.00,	2.00,	0.00);

-- Reserva Catastrofica

insert into sac:cglprepor
values (2009,	"563",	2.00,	2.00,	2.00,	2.00,	2.00,	2.00,	2.00,	2.00,	2.00,	2.00,	2.00,	2.00);


-- Otros Gastos Adquisicion

insert into sac:cglprepor
values (2009,	"564",	2.75,	2.75,	2.75,	2.75,	2.75,	2.75,	2.75,	2.75,	2.75,	2.75,	2.75,	2.75);


return 0, "Actualizacion Exitosa";

end procedure 