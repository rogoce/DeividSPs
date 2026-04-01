-- Retorna el Resumen Historico de gestiones por dia en detalle
-- Para un gestor y dia dado
-- 
-- Creado    : 10/09/2003 - Autor:Armando Moreno
-- Modificado: 10/09/2003 - Autor:Armando Moreno
--

drop procedure sp_cas68;

create procedure sp_cas68(a_cod_cobrador char(3), a_fecha_desde date, a_fecha_hasta date)
returning char(50),
		  char(100),
		  char(10),
		  datetime year to fraction(5),
		  datetime year to fraction(5),
          char(3),
		  char(8),
		  char(50),
          char(3),
          char(8),
          char(50),
          integer,
          integer,
          integer,
          integer,
          integer,
          integer,
          integer,
          integer,
          integer,
          char(3),
          date,
		  date,
          char(20),
		  varchar(50);

define _nombre_pagador	char(100);
define _nombre_cobrador	char(50);
define _nombre_ausencia	char(50);
define _nombre_gestion	char(50);
define _campana			varchar(50);
define _contacto		char(20);
define _hora_dif		char(30);
define _hora_dif_sum	char(15);
define _cod_pagador_ant	char(10);
define _cod_pagador		char(10);
define _user_added		char(8);
define _hora_min		char(8);
define _cod_ausencia	char(3);
define _cod_gestion		char(3);
define _hora_num2		integer;
define _hora_num3		integer;
define _hora_num		integer;
define _min_num2		integer;
define _seg_num2		integer;
define _min_num3		integer;
define _seg_num3		integer;
define _min_num			integer;
define _seg_num			integer;
define _tipo_contacto	smallint;
define _tipo_accion		smallint;
define _secuencia		smallint;
define _hora_min_interv	interval hour to second;
define _hora_dif_ant	interval hour to second;
define _fecha_ini		datetime year to fraction(5);
define _fecha_fin		datetime year to fraction(5);

--set debug file to "sp_cas68.trc";
--trace on;

CREATE TEMP TABLE temp_cobcahis
             (nombre_cobrador	char(50),
              nombre_pagador	char(100),
              cod_pagador		char(10),
              fecha_ini			datetime year to fraction(5),
              fecha_fin			datetime year to fraction(5),
              cod_gestion		char(3),
              user_added		char(8),
              nombre_gestion	char(50),
              cod_ausencia		char(3),
              hora_min			char(8),
              nombre_ausencia	char(50),
              min_num			integer,
              seg_num			integer,
              hora_num2			integer,
              min_num2			integer,
              seg_num2			integer,
              hora_num3			integer,
              min_num3			integer,
			  seg_num3			integer,
			  hora_num			integer,
			  contacto			char(20),
			  secuencia			smallint,
			  campana			varchar(50))
              WITH NO LOG;


let	_cod_pagador_ant = '';
let	_secuencia = 0;
let _campana = '';

foreach
	select cod_pagador,
    	   cod_gestion,
		   fecha_ini,
		   fecha_fin,
		   user_added,
		   cod_ausencia
	  into _cod_pagador,
	  	   _cod_gestion,
	  	   _fecha_ini,
	  	   _fecha_fin,
	  	   _user_added,
	  	   _cod_ausencia
	  from cobcahis
	 where date(fecha_ini) between a_fecha_desde and a_fecha_hasta
	   and cod_cobrador    = a_cod_cobrador


	if _fecha_fin < _fecha_ini then
		let _fecha_fin = _fecha_ini;
	end if
	let _hora_dif = _fecha_fin - _fecha_ini;
	let _hora_dif = trim(_hora_dif);
	let _hora_min = _hora_dif[3,10];

	let _seg_num2  = 0;
	let _min_num2  = 0;
	let _hora_num2 = 0;
	let _seg_num   = 0;
	let _min_num   = 0;
	let _hora_num  = 0;
	let _seg_num3  = 0;
	let _min_num3  = 0;
	let _hora_num3 = 0;
	let _contacto = '';
	
	select nombre
	  into _nombre_cobrador
	  from cobcobra
	 where cod_cobrador = a_cod_cobrador;

{	select upper(nombre)
	  into _campana
	  from cascampana
	 where cod_campana = _cod_campana;}

	if _cod_gestion is not null then	--tiempos con gestion
		if _cod_pagador_ant = _cod_pagador then
			select hora_min
			  into _hora_dif_ant
			  from temp_cobcahis
			 where secuencia = _secuencia;

			let _hora_min_interv = _hora_min;		 
			let _hora_dif_sum	 = _hora_dif_ant + _hora_min_interv;
			let _hora_min		 = trim(_hora_dif_sum);
			 
			update temp_cobcahis
			   set fecha_fin = _fecha_fin,
			   	   hora_min	 = _hora_min
			 where secuencia = _secuencia;

			let _cod_pagador_ant = _cod_pagador;		 
			continue foreach;			
		end if

		let _cod_pagador_ant = _cod_pagador;
		let _hora_num = _hora_dif[3,4];
		let _min_num  = _hora_dif[6,7];
		let _seg_num  = _hora_dif[9,10];

		select tipo_contacto,
			   tipo_accion
		  into _tipo_contacto,
			   _tipo_accion
		  from cobcages
		 where cod_gestion = _cod_gestion;

		if _tipo_contacto = 1 then
			let _contacto = 'Contacto Efectivo';
		elif _tipo_contacto = 2 then
			let _contacto = 'Contacto No Efectivo';	
		else
			let _contacto = 'No Contacto';
		end if
		
		if _tipo_accion in (12,13) then
			let _campana = 'Campaña de Anulación de Pólizas';
		else
			let _campana = 'Campaña de Gestión de Pólizas';
		end if

	else
		if _cod_ausencia is null then	--tiempos oseo sin ausencia
			let _hora_num2 = _hora_dif[3,4];
			let _min_num2  = _hora_dif[6,7];
			let _seg_num2  = _hora_dif[9,10];
		else
			let _hora_num3 = _hora_dif[3,4];
			let _min_num3  = _hora_dif[6,7];
			let _seg_num3  = _hora_dif[9,10];
		end if
	end if

	select nombre
	  into _nombre_pagador
	  from cliclien
	 where cod_cliente = _cod_pagador;

	select nombre
	  into _nombre_gestion
	  from cobcages
	 where cod_gestion = _cod_gestion;

	select nombre
	  into _nombre_ausencia
	  from cobcaaus
	 where cod_ausencia = _cod_ausencia;

	let _secuencia = _secuencia + 1;

	insert into temp_cobcahis(nombre_cobrador,
			   				  nombre_pagador,
			   				  cod_pagador,
			   				  fecha_ini,
			   				  fecha_fin,
			   				  cod_gestion,
			   				  user_added,
			   				  nombre_gestion,
			   				  cod_ausencia,
			   				  hora_min,
			   				  nombre_ausencia,
			   				  min_num,
			   				  seg_num,
			   				  hora_num2,
			   				  min_num2,
			   				  seg_num2,
			   				  hora_num3,
			   				  min_num3,
			   				  seg_num3,
			   				  hora_num,
			   				  contacto,
			   				  secuencia,
							  campana)
					   values(_nombre_cobrador,
					   		  _nombre_pagador,
					   		  _cod_pagador,
					   		  _fecha_ini,
					   		  _fecha_fin,
					   		  _cod_gestion,
					   		  _user_added,
					   		  _nombre_gestion,
					   		  _cod_ausencia,
					   		  _hora_min,
					   		  _nombre_ausencia,
					   		  _min_num,
					   		  _seg_num,
					   		  _hora_num2,
					   		  _min_num2,
					    	  _seg_num2,
							  _hora_num3,
							  _min_num3,
							  _seg_num3,
							  _hora_num,
							  _contacto,
							  _secuencia,
							  _campana); 

end foreach

foreach
	select nombre_cobrador, 
		   nombre_pagador,
		   cod_pagador,
		   fecha_ini,
		   fecha_fin,
		   cod_gestion,
		   user_added,
		   nombre_gestion,
		   cod_ausencia,
		   hora_min,
		   nombre_ausencia,
		   min_num,
		   seg_num,
		   hora_num2,
		   min_num2,
		   seg_num2,
		   hora_num3,
		   min_num3,
		   seg_num3,
		   hora_num,
		   contacto,
		   campana
	  into _nombre_cobrador,
		   _nombre_pagador,
		   _cod_pagador,
		   _fecha_ini,
		   _fecha_fin,
		   _cod_gestion,
		   _user_added,
		   _nombre_gestion,
		   _cod_ausencia,
		   _hora_min,
		   _nombre_ausencia,
		   _min_num,
		   _seg_num,
		   _hora_num2,
		   _min_num2,
		   _seg_num2,
		   _hora_num3,
		   _min_num3,
		   _seg_num3,
		   _hora_num,
		   _contacto,
		   _campana
	  from temp_cobcahis
	 order by fecha_ini	 

	return _nombre_cobrador,
		   _nombre_pagador,
		   _cod_pagador,
		   _fecha_ini,
		   _fecha_fin,
		   _cod_gestion,
		   _user_added,
		   _nombre_gestion,
		   _cod_ausencia,
		   _hora_min,
		   _nombre_ausencia,
		   _min_num,
		   _seg_num,
		   _hora_num2,
		   _min_num2,
		   _seg_num2,
		   _hora_num3,
		   _min_num3,
		   _seg_num3,
		   _hora_num,
		   a_cod_cobrador,
		   a_fecha_desde,
		   a_fecha_hasta,
		   _contacto,
		   _campana
		   with resume;

end foreach
drop table temp_cobcahis;
end procedure;