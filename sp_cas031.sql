-- Retorna el Resumen Historico de Gestiones para un rango de fechas
-- Creado    : 24/04/2003 - Autor:Armando Moreno
-- Modificado: 24/04/2003 - Autor:Armando Moreno
--
-- SIS v.2.0 - d_cobr_sp_cob100_dw1 - DEIVID, S.A.

drop procedure sp_cas031;

create procedure sp_cas031(a_fecha_desde date, a_fecha_hasta date, a_cod_cobrador char(3) default '*')
returning varchar(50),
          smallint,
          smallint,
          smallint,
          smallint,
          smallint,
          smallint,
          smallint,
          smallint,
          smallint,
          smallint,
          smallint,
          varchar(50),
          varchar(50),
          varchar(50),
          varchar(50),
          varchar(50),
          varchar(50),
          varchar(50),
          varchar(50),
          varchar(50),
          varchar(50),
          smallint;

define _nombre_gestor10	varchar(50);
define _nombre_gestor9	varchar(50);
define _nombre_gestor8	varchar(50);
define _nombre_gestor7	varchar(50);
define _nombre_gestor6	varchar(50);
define _nombre_gestor5	varchar(50);
define _nombre_gestor4	varchar(50);
define _nombre_gestor3	varchar(50);
define _nombre_gestor2	varchar(50);
define _nombre_gestor1	varchar(50);
define _nombre			varchar(50);
define _cod_cobrador	char(3);
define _cod_gestor10	char(3);
define _cod_gestor9		char(3);
define _cod_gestor8		char(3);
define _cod_gestor7		char(3);
define _cod_gestor6		char(3);
define _cod_gestor5		char(3);
define _cod_gestor4		char(3);
define _cod_gestor3		char(3);
define _cod_gestor2		char(3);
define _cod_gestor1		char(3);
define _cod_gestion		char(3);
define _cant_gestor_tot	smallint;
define _tipo_contacto	smallint;
define _cant_gestor10	smallint;
define _cant_gestor9	smallint;
define _cant_gestor8	smallint;
define _cant_gestor7	smallint;
define _cant_gestor6	smallint;
define _cant_gestor5	smallint;
define _cant_gestor4	smallint;
define _cant_gestor3	smallint;
define _cant_gestor2	smallint;
define _cant_gestor1	smallint;
define _cant_gestor		smallint;
define _cantidad		smallint;

create temp table tmp_resges(
cod_gestion		char(3),
cant_gestor1	smallint default 0,
cant_gestor2	smallint default 0,
cant_gestor3	smallint default 0,
cant_gestor4	smallint default 0,
cant_gestor5	smallint default 0,
cant_gestor6	smallint default 0,
cant_gestor7	smallint default 0,
cant_gestor8	smallint default 0,
cant_gestor9	smallint default 0,
cant_gestor10	smallint default 0,
cod_gestor1		char(3)  default "",
cod_gestor2		char(3)  default "",
cod_gestor3		char(3)  default "",
cod_gestor4		char(3)  default "",
cod_gestor5		char(3)  default "",
cod_gestor6		char(3)  default "",
cod_gestor7		char(3)  default "",
cod_gestor8		char(3)  default "",
cod_gestor9		char(3)  default "",
cod_gestor10	char(3)  default "",
primary key (cod_gestion)
) with no log;

create temp table tmp_cobradores(
cod_cobrador	char(3)) with no log;

if a_cod_cobrador = '*' then
	foreach
		select h.cod_cobrador
		  into _cod_cobrador
		  from cobcahis h, cobcobra c
		 where date(h.fecha_ini) >= a_fecha_desde
		   and date(h.fecha_ini) <= a_fecha_hasta
		   and h.cod_gestion is not null
		   and h.cod_cobrador = c.cod_cobrador
		   and c.tipo_cobrador not in (7, 8) 
		 group by 1
		 order by 1

		insert into tmp_cobradores(cod_cobrador)
		values (_cod_cobrador);
	end foreach
else
	insert into tmp_cobradores(cod_cobrador)
	values (a_cod_cobrador);
end if	

-- Gestiones
foreach
	select cod_gestion
	  into _cod_gestion
	  from cobcages

	insert into tmp_resges(cod_gestion)
	values(_cod_gestion);
end foreach

-- Gestores
let _cant_gestor = 0;

foreach
	select h.cod_cobrador
	  into _cod_cobrador
	  from cobcahis h, cobcobra c
	 where date(h.fecha_ini) >= a_fecha_desde
	   and date(h.fecha_ini) <= a_fecha_hasta
	   and h.cod_gestion is not null
	   and h.cod_cobrador = c.cod_cobrador
	   and c.cod_cobrador in (select cod_cobrador from tmp_cobradores)
	   and c.tipo_cobrador not in (7, 8) 
	 group by 1
	 order by 1

	let _cant_gestor = _cant_gestor + 1;

	if _cant_gestor = 1 then
		update tmp_resges
		   set cod_gestor1  = _cod_cobrador;
	elif _cant_gestor = 2 then
		update tmp_resges
		   set cod_gestor2  = _cod_cobrador;
	elif _cant_gestor = 3 then
		update tmp_resges
		   set cod_gestor3  = _cod_cobrador;
	elif _cant_gestor = 4 then
		update tmp_resges
		   set cod_gestor4  = _cod_cobrador;
	elif _cant_gestor = 5 then
		update tmp_resges
		   set cod_gestor5  = _cod_cobrador;
	elif _cant_gestor = 6 then
		update tmp_resges
		   set cod_gestor6  = _cod_cobrador;
	elif _cant_gestor = 7 then
		update tmp_resges
		   set cod_gestor7  = _cod_cobrador;
	elif _cant_gestor = 8 then
		update tmp_resges
		   set cod_gestor8  = _cod_cobrador;
	elif _cant_gestor = 9 then
		update tmp_resges
		   set cod_gestor9  = _cod_cobrador;
	elif _cant_gestor = 10 then
		update tmp_resges
		   set cod_gestor10  = _cod_cobrador;
	end if
end foreach

--{
let _cant_gestor = 0;

foreach
	select h.cod_cobrador
	  into _cod_cobrador
	  from cobcahis h, cobcobra c
	 where date(h.fecha_ini) >= a_fecha_desde
	   and date(h.fecha_ini) <= a_fecha_hasta
	   and h.cod_gestion is not null
	   and h.cod_cobrador = c.cod_cobrador
	   and c.cod_cobrador in (select cod_cobrador from tmp_cobradores)
	   and c.tipo_cobrador not in (7, 8) 
	 group by 1
	 order by 1

	let _cant_gestor = _cant_gestor + 1;

	foreach
		select cod_gestion,
			   count(*)
		  into _cod_gestion,
			   _cantidad
		  from cobcahis
		 where cod_cobrador = _cod_cobrador
		   and cod_gestion  is not null
		   and date(fecha_ini) >= a_fecha_desde
		   and date(fecha_ini) <= a_fecha_hasta
		 group by 1

		if _cant_gestor = 1 then
			update tmp_resges
			   set cant_gestor1 = _cantidad
			 where cod_gestion  = _cod_gestion;
		elif _cant_gestor = 2 then
			update tmp_resges
			   set cant_gestor2 = _cantidad
			 where cod_gestion  = _cod_gestion;
		elif _cant_gestor = 3 then
			update tmp_resges
			   set cant_gestor3 = _cantidad
			 where cod_gestion  = _cod_gestion;
		elif _cant_gestor = 4 then
			update tmp_resges
			   set cant_gestor4 = _cantidad
			 where cod_gestion  = _cod_gestion;
		elif _cant_gestor = 5 then
			update tmp_resges
			   set cant_gestor5 = _cantidad
			 where cod_gestion  = _cod_gestion;
		elif _cant_gestor = 6 then
			update tmp_resges
			   set cant_gestor6 = _cantidad
			 where cod_gestion  = _cod_gestion;
		elif _cant_gestor = 7 then
			update tmp_resges
			   set cant_gestor7 = _cantidad
			 where cod_gestion  = _cod_gestion;
		elif _cant_gestor = 8 then
			update tmp_resges
			   set cant_gestor8 = _cantidad
			 where cod_gestion  = _cod_gestion;
		elif _cant_gestor = 9 then
			update tmp_resges
			   set cant_gestor9 = _cantidad
			 where cod_gestion  = _cod_gestion;
		elif _cant_gestor = 10 then
			update tmp_resges
			   set cant_gestor10 = _cantidad
			 where cod_gestion   = _cod_gestion;
		end if
	end foreach
end foreach
--}

foreach
	select cod_gestion,
		   cant_gestor1,
		   cant_gestor2,
		   cant_gestor3,
		   cant_gestor4,
		   cant_gestor5,
		   cant_gestor6,
		   cant_gestor7,
		   cant_gestor8,
		   cant_gestor9,
		   cant_gestor10,
		   cod_gestor1,
		   cod_gestor2,
		   cod_gestor3,
		   cod_gestor4,
		   cod_gestor5,
		   cod_gestor6,
		   cod_gestor7,
		   cod_gestor8,
		   cod_gestor9,
		   cod_gestor10
	  into _cod_gestion,
		   _cant_gestor1,
		   _cant_gestor2,
		   _cant_gestor3,
		   _cant_gestor4,
		   _cant_gestor5,
		   _cant_gestor6,
		   _cant_gestor7,
		   _cant_gestor8,
		   _cant_gestor9,
		   _cant_gestor10,
		   _cod_gestor1,
		   _cod_gestor2,
		   _cod_gestor3,
		   _cod_gestor4,
		   _cod_gestor5,
		   _cod_gestor6,
		   _cod_gestor7,
		   _cod_gestor8,
		   _cod_gestor9,
		   _cod_gestor10
	  from tmp_resges   

	select nombre,
		   tipo_contacto
	  into _nombre,
		   _tipo_contacto	
	  from cobcages
	 where cod_gestion = _cod_gestion;

	select nombre
	  into _nombre_gestor1
	  from cobcobra
	 where cod_cobrador = _cod_gestor1;

	select nombre
	  into _nombre_gestor2
	  from cobcobra
	 where cod_cobrador = _cod_gestor2;

	select nombre
	  into _nombre_gestor3
	  from cobcobra
	 where cod_cobrador = _cod_gestor3;

	select nombre
	  into _nombre_gestor4
	  from cobcobra
	 where cod_cobrador = _cod_gestor4;

	select nombre
	  into _nombre_gestor5
	  from cobcobra
	 where cod_cobrador = _cod_gestor5;

	select nombre
	  into _nombre_gestor6
	  from cobcobra
	 where cod_cobrador = _cod_gestor6;

	select nombre
	  into _nombre_gestor7
	  from cobcobra
	 where cod_cobrador = _cod_gestor7;

	select nombre
	  into _nombre_gestor8
	  from cobcobra
	 where cod_cobrador = _cod_gestor8;

	select nombre
	  into _nombre_gestor9
	  from cobcobra
	 where cod_cobrador = _cod_gestor9;

	select nombre
	  into _nombre_gestor10
	  from cobcobra
	 where cod_cobrador = _cod_gestor10;

	let _cant_gestor_tot = _cant_gestor1 +
						   _cant_gestor2 +		    
						   _cant_gestor3 +		    
						   _cant_gestor4 +		    
						   _cant_gestor5 +		    
						   _cant_gestor6 +		    
						   _cant_gestor7 +		    
						   _cant_gestor8 +		    
						   _cant_gestor9 +		    
						   _cant_gestor10;


	if _nombre_gestor1 is null Then
		let _cant_gestor1 = null;
	end if

	if _nombre_gestor2 is null Then
		let _cant_gestor2 = null;
	end if

	if _nombre_gestor3 is null Then
		let _cant_gestor3 = null;
	end if

	if _nombre_gestor4 is null Then
		let _cant_gestor4 = null;
	end if
	if _nombre_gestor5 is null Then
		let _cant_gestor5 = null;
	end if

	if _nombre_gestor6 is null Then
		let _cant_gestor6 = null;
	end if

	if _nombre_gestor7 is null Then
		let _cant_gestor7 = null;
	end if

	if _nombre_gestor8 is null Then
		let _cant_gestor8 = null;
	end if

	if _nombre_gestor9 is null Then
		let _cant_gestor9 = null;
	end if

	if _nombre_gestor10 is null Then
		let _cant_gestor10 = null;
	end if

	return _nombre,
		   _tipo_contacto,
		   _cant_gestor1,
		   _cant_gestor2,
		   _cant_gestor3,
		   _cant_gestor4,
		   _cant_gestor5,
		   _cant_gestor6,
		   _cant_gestor7,
		   _cant_gestor8,
		   _cant_gestor9,
		   _cant_gestor10,
		   _nombre_gestor1,
		   _nombre_gestor2,
		   _nombre_gestor3,
		   _nombre_gestor4,
		   _nombre_gestor5,
		   _nombre_gestor6,
		   _nombre_gestor7,
		   _nombre_gestor8,
		   _nombre_gestor9,
		   _nombre_gestor10,
		   _cant_gestor_tot with resume;
end foreach
drop table if exists tmp_resges;
end procedure
