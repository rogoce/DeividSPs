-- Consulta de Clientes Global

-- Creado    : 14/06/2001 - Autor: Armando Moreno M.
-- Modificado: 14/06/2001 - Autor: Armando Moreno M.
-- Modificado: 21/04/2009 - Autor_ Amado Perez 

-- SIS v.2.0 - d_prod_sp_prd67_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_rwf02;

CREATE PROCEDURE sp_rwf02(a_cod_cliente CHAR(10))
RETURNING CHAR(20),	 -- POLIZA
		  CHAR(5),	 -- UNIDAD
		  char(10),  -- VIG INI
		  char(10),  -- VIG FIN
		  char(10),
		  char(10),
		  char(100),
		  char(30),
		  DATE,
		  smallint,
		  char(10);

DEFINE v_cod_cliente  		CHAR(10);  

DEFINE v_documento   		CHAR(20);
DEFINE v_vig_ini			DATE;
DEFINE v_vig_fin			DATE;
DEFINE v_fecha_aviso_canc   DATE;
DEFINE v_no_unidad	 	    CHAR(5);

DEFINE v_no_poliza	 	    CHAR(10);
define _actualizado			smallint;
DEFINE _no_endoso	 	    CHAR(5);
define _estatus_poliza		smallint;
define _estatus_desc		char(10);

define _descripcion			char(100);
define _no_motor			char(30);
define _cod_marca			char(5);
define _cod_modelo			char(5);
define _nombre_marca		char(50);
define _nombre_modelo		char(50);
define _cod_ramo			char(3);
define _ramo_sis            smallint;
define _leasing             smallint;
define _cod_leasing         char(10);
define _fecha_cancelacion   date;

--set debug file to "sp_rwf02.trc";

create temp table tmp_polizas(
	no_poliza	   char(10),
	no_unidad	   char(5),
	vigencia_inic  date,
	vigencia_final date,
	leasing        smallint,
	cod_leasing    char(10),
   	PRIMARY KEY (no_poliza, no_unidad)
	) with no log;

create temp table tmp_documento(
	no_documento	 char(20),
	no_unidad		 char(5),
	vigencia_inic	 date,
	vigencia_final	 date,
	estatus_desc	 char(10),
	no_poliza		 char(10),
	cod_ramo		 char(3),
	fecha_aviso_canc date,
	leasing          smallint,
	cod_leasing      char(10),
	fecha_cancelacion date
	) with no log;

CREATE INDEX idx1_no_documento ON tmp_documento(no_documento);
CREATE INDEX idx1_no_unidad ON tmp_documento(no_unidad);
CREATE INDEX idx1_vigencia_inic ON tmp_documento(vigencia_inic);

SET ISOLATION TO DIRTY READ;

FOREACH
 SELECT	a.no_poliza,
        a.no_unidad,
		a.no_endoso,
		a.vigencia_inic,
		a.vigencia_final,
		b.leasing,
		a.cod_cliente
   INTO v_no_poliza,
        v_no_unidad,
		_no_endoso,
		v_vig_ini,
		v_vig_fin,
		_leasing,
		_cod_leasing
   FROM	endeduni a, emipomae b  
  WHERE cod_cliente = a_cod_cliente
    AND a.no_poliza = b.no_poliza
	AND b.cod_ramo in ('002','020')	--> Se agrego para que traiga solo automovil
  ORDER BY no_poliza, no_unidad, no_endoso desc

	select actualizado
	  into _actualizado
	  from endedmae
	 where no_poliza = v_no_poliza
	   and no_endoso = _no_endoso;

	if _actualizado = 0 then
		continue foreach;
	end if

	BEGIN                                         
                                              
		ON EXCEPTION IN(-239,-268)                     
		END EXCEPTION                             

		insert into tmp_polizas
		values (v_no_poliza, v_no_unidad, v_vig_ini, v_vig_fin, _leasing, _cod_leasing);
		                                          
	END                                           

END FOREACH

FOREACH
 SELECT	no_poliza,
        leasing
   INTO v_no_poliza,
        _leasing
   FROM	emipomae 
  WHERE actualizado      = 1
    AND cod_ramo in ('002','020')  --> Se agrego para que traiga solo automovil
    and (cod_pagador     = a_cod_cliente or
		 cod_contratante = a_cod_cliente)

	foreach
	 select	no_unidad,
	        no_endoso,
			vigencia_inic,
			vigencia_final,
			cod_cliente
	   into v_no_unidad,
	        _no_endoso,
			v_vig_ini,
			v_vig_fin,
			_cod_leasing
	   from endeduni
	  where no_poliza = v_no_poliza

		select actualizado
		  into _actualizado
		  from endedmae
		 where no_poliza = v_no_poliza
		   and no_endoso = _no_endoso;

		if _actualizado = 0 then
			continue foreach;
		end if

	BEGIN                                         
                                              
		ON EXCEPTION IN(-239,-268)                     
		END EXCEPTION                             

		insert into tmp_polizas
		values (v_no_poliza, v_no_unidad, v_vig_ini, v_vig_fin, _leasing, _cod_leasing);
		                                          
	END                                           

	end foreach

END FOREACH

foreach
 select no_poliza,
        no_unidad,
		vigencia_inic, 
		vigencia_final, 
		leasing, 
		cod_leasing
   into v_no_poliza,
        v_no_unidad,
		v_vig_ini,
		v_vig_fin, 
		_leasing, 
		_cod_leasing
   from tmp_polizas
--  group by 1, 2

	SELECT	no_documento,
 --	 		vigencia_inic,
 --			vigencia_final,
			estatus_poliza,
			cod_ramo,
            fecha_aviso_canc,
			fecha_cancelacion
	   INTO	v_documento,
   --	   		v_vig_ini,
   --			v_vig_fin,
			_estatus_poliza,
			_cod_ramo,
		    v_fecha_aviso_canc,
			_fecha_cancelacion
	   FROM	emipomae
	  WHERE no_poliza = v_no_poliza;

	if _estatus_poliza = 1 then
		let _estatus_desc = "VIGENTE";
	elif _estatus_poliza = 2 then
		let _estatus_desc = "CANCELADA";
	elif _estatus_poliza = 3 then
		let _estatus_desc = "VENCIDA";
	elif _estatus_poliza = 4 then
		let _estatus_desc = "ANULADA";
	end if

	insert into tmp_documento
	values (v_documento, v_no_unidad, v_vig_ini, v_vig_fin, _estatus_desc, v_no_poliza, _cod_ramo, v_fecha_aviso_canc, _leasing, _cod_leasing, _fecha_cancelacion);

end foreach

foreach
 select no_documento,
	 	no_unidad,
		vigencia_inic,
		vigencia_final,
		estatus_desc,
		no_poliza,
		cod_ramo,
		fecha_aviso_canc, 
		leasing, 
		cod_leasing,
		fecha_cancelacion
   into v_documento,
	   	v_no_unidad,
        v_vig_ini,
		v_vig_fin,
		_estatus_desc,
		v_no_poliza,
		_cod_ramo,
		v_fecha_aviso_canc, 
		_leasing, 
		_cod_leasing,
		_fecha_cancelacion
   from tmp_documento
  order by 1, 2, 3 Desc

	let _descripcion = "";
	let _no_motor = "";

    select ramo_sis
	  into _ramo_sis
	  from prdramo
	 where cod_ramo = _cod_ramo;

	if _ramo_sis = 1 then

		select no_motor
		  into _no_motor
		  from emiauto
		 where no_poliza = v_no_poliza
		   and no_unidad = v_no_unidad;

		if _no_motor is null or _no_motor = "" then

			foreach
			 select no_motor
			   into _no_motor
			   from endmoaut
		      where no_poliza = v_no_poliza
		        and no_unidad = v_no_unidad
				exit foreach;
			end foreach
		    let _descripcion = "ELIMINADA-";
		end if

		if _no_motor is not null or _no_motor <> "" then

			select cod_marca,
			       cod_modelo
			  into _cod_marca,
			       _cod_modelo
			  from emivehic
			 where no_motor = _no_motor;
			 
			 select nombre
			   into _nombre_marca
			   from emimarca
			  where cod_marca = _cod_marca;

			 select nombre
			   into _nombre_modelo
			   from emimodel
			  where cod_modelo = _cod_modelo;

			let _descripcion = trim(_descripcion) || trim(_nombre_marca) || " " || trim(_nombre_modelo) || " " || _no_motor;

		end if
	
	end if
	
	RETURN  v_documento,
			v_no_unidad,		 
			v_vig_ini,
			v_vig_fin,
			_estatus_desc,
			v_no_poliza,
			_descripcion,
			Trim(_no_motor),
			v_fecha_aviso_canc, 
			_leasing, 
			_cod_leasing
			WITH RESUME;

end foreach

drop table tmp_polizas;
drop table tmp_documento;

END PROCEDURE;