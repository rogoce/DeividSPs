-- Consulta de Clientes Global

-- Creado    : 14/06/2001 - Autor: Armando Moreno M.
-- Modificado: 14/06/2001 - Autor: Armando Moreno M.
-- Modificado: 21/04/2009 - Autor_ Amado Perez 

-- SIS v.2.0 - d_prod_sp_prd67_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_rwf118;

CREATE PROCEDURE sp_rwf118(a_cod_cliente CHAR(10), a_motor VARCHAR(30) DEFAULT "%")
RETURNING char(10),  -- VIG INI
		  char(10),  -- VIG FIN
		  char(10),
		  smallint,
		  char(10),
		  char(10),
		  char(50),
		  varchar(255),
		  char(3),
		  char(50);

DEFINE v_cod_cliente  		char(10);  

DEFINE v_documento   		char(20);
DEFINE v_vig_ini			DATE;
DEFINE v_vig_fin			DATE;
DEFINE v_fecha_aviso_canc   DATE;
DEFINE v_no_unidad	 	    CHAR(5);

DEFINE v_no_poliza	 	    char(10);
define _actualizado			smallint;
DEFINE _no_endoso	 	    char(5);
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
DEFINE _vigengia_inic		DATE;
DEFINE _vigengia_fin		DATE;

define v_cod_agente	 	    CHAR(5);
define v_nombre_corredor    char(50); 
define v_email_corredor 	varchar(255);
define v_cod_ramo 			char(3);
define v_nombre_ramo 		char(50);
define v_suma_asegurada 	DEC(16,2);
define v_motor				char(30);

DEFINE _email               VARCHAR(50);

--set debug file to "sp_rwf02.trc";

create temp table tmp_polizas(
	no_poliza	   char(10),
	no_unidad	   char(5),
	vigencia_inic  date,
	vigencia_final date,
	leasing        smallint,
	cod_leasing    char(10),
	vig_inic_pol   date,
	vig_final_pol  date,
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
	fecha_cancelacion date,
	vig_inic_pol     date,
	vig_final_pol    date,
   	PRIMARY KEY (no_documento, no_unidad, vig_inic_pol, vig_final_pol)
	) with no log;

--CREATE INDEX idx1_no_documento ON tmp_documento(no_documento);
--CREATE INDEX idx1_no_unidad ON tmp_documento(no_unidad);
--CREATE INDEX idx1_vigencia_inic ON tmp_documento(vigencia_inic);

SET ISOLATION TO DIRTY READ;

IF TRIM(a_motor) = "" THEN
	LET a_motor = "%";
END IF

FOREACH
 SELECT	a.no_poliza,
        a.no_unidad,
		a.no_endoso,
		a.vigencia_inic,
		a.vigencia_final,
		b.leasing,
		a.cod_cliente,
		b.vigencia_inic,
		b.vigencia_final
   INTO v_no_poliza,
        v_no_unidad,
		_no_endoso,
		v_vig_ini,
		v_vig_fin,
		_leasing,
		_cod_leasing,
		_vigengia_inic,
		_vigengia_fin	
   FROM	endeduni a, emipomae b  
  WHERE a.cod_cliente = a_cod_cliente
    AND a.no_poliza = b.no_poliza
	AND b.cod_ramo in ('002','020')	--> Se agrego para que traiga solo automovil
--  ORDER BY a.no_poliza, a.no_unidad, a.no_endoso desc

	select actualizado
	  into _actualizado
	  from endedmae
	 where no_poliza = v_no_poliza
	   and no_endoso = _no_endoso;

	if _actualizado = 0 OR v_vig_fin Is Null then
		continue foreach;
	end if

	BEGIN                                         
                                              
		ON EXCEPTION IN(-239,-268)                     
		END EXCEPTION                             

		insert into tmp_polizas
		values (v_no_poliza, v_no_unidad, v_vig_ini, v_vig_fin, _leasing, _cod_leasing, _vigengia_inic, _vigengia_fin);
		                                          
	END                                           

END FOREACH

FOREACH
 SELECT	no_poliza,
        leasing,
		vigencia_inic,
		vigencia_final
   INTO v_no_poliza,
        _leasing,
		_vigengia_inic,
		_vigengia_fin	
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

		if _actualizado = 0 OR v_vig_fin Is Null then
			continue foreach;
		end if

	BEGIN                                         
                                              
		ON EXCEPTION IN(-239,-268)                     
		END EXCEPTION                             

		insert into tmp_polizas
		values (v_no_poliza, v_no_unidad, v_vig_ini, v_vig_fin, _leasing, _cod_leasing, _vigengia_inic, _vigengia_fin);
		                                          
	END                                           

	end foreach

END FOREACH

foreach
 select no_poliza,
        no_unidad,
		vigencia_inic, 
		vigencia_final, 
		leasing, 
		cod_leasing,
		vig_inic_pol, 
		vig_final_pol
   into v_no_poliza,
        v_no_unidad,
		v_vig_ini,
		v_vig_fin, 
		_leasing, 
		_cod_leasing,
		_vigengia_inic,
		_vigengia_fin	
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

	BEGIN                         --> 21/09/2010 SE AGREGO PARA QUE SEA MAS RAPIDO                
                                              
		ON EXCEPTION IN(-239,-268)                     
		END EXCEPTION                             

		insert into tmp_documento
		values (v_documento, v_no_unidad, v_vig_ini, v_vig_fin, _estatus_desc, v_no_poliza, _cod_ramo, v_fecha_aviso_canc, _leasing, _cod_leasing, _fecha_cancelacion, _vigengia_inic, _vigengia_fin);
	END

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

 foreach
	 select vigencia_final
	   into v_vig_fin
	   from endeduni
	  where no_poliza = v_no_poliza
	    and no_unidad = v_no_unidad
   order by no_endoso desc
   exit foreach;
 end foreach 

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
		   and no_unidad = v_no_unidad
		   and no_motor like a_motor;

		if _no_motor is null or _no_motor = "" then
			foreach
			 select no_motor
			   into _no_motor
			   from endmoaut
		      where no_poliza = v_no_poliza
		        and no_unidad = v_no_unidad
				and no_motor like a_motor
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
		else
			if a_motor <> "%" then
				continue foreach;
			end if
		end if
	
	end if

	SELECT cod_ramo
	  INTO v_cod_ramo
	  FROM emipomae
	 WHERE no_poliza = v_no_poliza;

	SELECT nombre
	  INTO v_nombre_ramo
	  FROM prdramo
	 WHERE cod_ramo = v_cod_ramo;

	FOREACH
	 SELECT	cod_agente
	   INTO	v_cod_agente
	   FROM	emipoagt
	  WHERE no_poliza = v_no_poliza
		EXIT FOREACH;
	END FOREACH

	LET v_email_corredor = "";
	
	SELECT nombre,
	       email_reclamo
	  INTO v_nombre_corredor,
		   v_email_corredor	
	  FROM agtagent
	 WHERE cod_agente = v_cod_agente;

	IF v_email_corredor is null THEN
		LET v_email_corredor = "";
	END IF
	 
	LET _email = "";

	FOREACH
		SELECT email
		  INTO _email
		  FROM agtmail
		 WHERE cod_agente = v_cod_agente
		   AND tipo_correo = "REC"
		
		IF TRIM(_email) <> "" OR _email IS NOT NULL THEN
			IF TRIM(v_email_corredor) <> "" THEN
				LET v_email_corredor = TRIM(v_email_corredor) || ";" || TRIM(_email);
			ELSE
				LET v_email_corredor = TRIM(_email);
			END IF
		END IF
	END FOREACH
	
	RETURN  v_vig_ini,
			v_vig_fin,
			v_fecha_aviso_canc, 
			_leasing, 
			_cod_leasing,
			_fecha_cancelacion,
			v_nombre_corredor, 
			v_email_corredor, 
			v_cod_ramo, 
			v_nombre_ramo
			WITH RESUME;

end foreach

drop table tmp_polizas;
drop table tmp_documento;

END PROCEDURE;