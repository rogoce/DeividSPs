-- Procedimiento para crear la carta del suntracs -- 
-- Creado    : 10/03/2010 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_pro1008;
CREATE PROCEDURE "informix".sp_pro1008 (a_poliza CHAR(10)) 
RETURNING   CHAR(10),   -- v_no_poliza 
 			CHAR(20),   -- v_no_documento
            char(100),	-- vig inicial
			char(100),	-- vig final
			char(100),  -- aseg.
			char(100),  -- fecha actual
		 varchar(100),
		 decimal(16,2),
		 decimal(16,2),
		 decimal(16,2),
		 decimal(16,2),
		 varchar(50),
		 decimal(16,2),
		 varchar(50),
		 decimal(16,2),
		 varchar(50),
		 decimal(16,2),
		 varchar(50),
		 decimal(16,2),
		 varchar(50),
		 decimal(16,2),
		 varchar(50),
		 decimal(16,2),
		 varchar(50),
		 decimal(16,2),
		 varchar(50);

DEFINE _documento		 CHAR(20);
define _vig_ini			 date;
define _vig_fin			 date;
define _fecha_ini        char(100);
define _fecha_fin		 char(100);
define _cod_contratante  char(10);
DEFINE _asegurado		 CHAR(100);
define _fecha_actual     char(100);
define _fecha            date;
define _direccion		 varchar(100);
define _direccion_1      varchar(50);
define _prima_neta		 decimal(16,2);
define _impuesto		 decimal(16,2);
define _prima_bruta		 decimal(16,2);
define _direccion_2      varchar(50);
define _limite_cob_a	 decimal(16,2);
define _deducible_cob_a	 varchar(50);
define _limite_cob_est	   decimal(16,2);
define _deducible_cob_est  varchar(50);
define _limite_cob_equ	   decimal(16,2);
define _deducible_cob_equ  varchar(50);
define _limite_maq		   decimal(16,2);
define _deducible_maq	   varchar(50);
define _limite_remo		   decimal(16,2);
define _deducible_remo	   varchar(50);
define _limite_cob_b	   decimal(16,2);
define _deducible_cob_b	   varchar(50);
define _limite_cob_c	   decimal(16,2);
define _deducible_cob_c	   varchar(50);
define _limite_cob_l	   decimal(16,2);
define _deducible_cob_l	   varchar(50);
define _cnt				   smallint;

let _fecha = current;

SET ISOLATION TO DIRTY READ;

let _fecha_actual = "";

-- Lectura de emipomae
SELECT no_documento,
       vigencia_inic,
	   vigencia_final,
	   cod_contratante,
	   prima_neta,
	   impuesto,
	   prima_bruta
  INTO _documento,
       _vig_ini,
       _vig_fin,
	   _cod_contratante,
	   _prima_neta,
	   _impuesto,
	   _prima_bruta
  FROM emipomae
 WHERE no_poliza = a_poliza 
   AND actualizado = 1;

let _asegurado = "";

SELECT trim(upper(nombre)),
       trim(direccion_1),
	   trim(direccion_2)
  INTO _asegurado,
       _direccion_1,
	   _direccion_2
  FROM cliclien
 WHERE cod_cliente = _cod_contratante;

if _direccion_1 is null then
	let _direccion_1 = "";
end if

if _direccion_2 is null then
	let _direccion_2 = "";
end if

let _direccion = _direccion_1 || _direccion_2;

call sp_sis20(_vig_ini) returning _fecha_ini;
call sp_sis20(_vig_fin) returning _fecha_fin;
call sp_sis20(_fecha)   returning _fecha_actual;

select count(*)
  into _cnt
  from emipocob
 where no_poliza     = a_poliza
   and cod_cobertura = "00358";	--Cobertura Basica A

if _cnt > 0 then

	foreach
		select limite_1,
		       deducible
		  into _limite_cob_a,
		       _deducible_cob_a
		  from emipocob
		 where no_poliza     = a_poliza
		   and cod_cobertura = "00358"

		exit foreach;
	end foreach
else
	let _deducible_cob_a = "";
	let _limite_cob_a  = 0;
end if
-----------------------------------
select count(*)
  into _cnt
  from emipocob
 where no_poliza     = a_poliza
   and cod_cobertura = "00365";	--Estructura Adyacente

if _cnt > 0 then

	foreach
		select limite_1,
		       deducible
		  into _limite_cob_est,
		       _deducible_cob_est
		  from emipocob
		 where no_poliza     = a_poliza
		   and cod_cobertura = "00365"

		exit foreach;
	end foreach
else
	let _deducible_cob_est = "";
	let _limite_cob_est    = 0;
end if
-----------------------------------------
select count(*)
  into _cnt
  from emipocob
 where no_poliza     = a_poliza
   and cod_cobertura = "00994";	--Equipo de Construccion

if _cnt > 0 then

	foreach
		select limite_1,
		       deducible
		  into _limite_cob_equ,
		       _deducible_cob_equ
		  from emipocob
		 where no_poliza     = a_poliza
		   and cod_cobertura = "00994"

		exit foreach;
	end foreach
else
	let _deducible_cob_equ = "";
	let _limite_cob_equ  = 0;
end if
-------------------------------------------
select count(*)
  into _cnt
  from emipocob
 where no_poliza     = a_poliza
   and cod_cobertura = "00995";	--Maquinaria de Construccion

if _cnt > 0 then

	foreach
		select limite_1,
		       deducible
		  into _limite_maq,
		       _deducible_maq
		  from emipocob
		 where no_poliza     = a_poliza
		   and cod_cobertura = "00995"

		exit foreach;
	end foreach
else
	let _deducible_maq = "";
	let _limite_maq  = 0;
end if
------------------------------------
select count(*)
  into _cnt
  from emipocob
 where no_poliza     = a_poliza
   and cod_cobertura = "00364";	--Remocion de escombros

if _cnt > 0 then

	foreach
		select limite_1,
		       deducible
		  into _limite_remo,
		       _deducible_remo
		  from emipocob
		 where no_poliza     = a_poliza
		   and cod_cobertura = "00364"

		exit foreach;
	end foreach
else
	let _deducible_remo = "";
	let _limite_remo  = 0;
end if
---------------------------------
select count(*)
  into _cnt
  from emipocob
 where no_poliza     = a_poliza
   and cod_cobertura = "00359";	--cobertura B

if _cnt > 0 then

	foreach
		select limite_1,
		       deducible
		  into _limite_cob_b,
		       _deducible_cob_b
		  from emipocob
		 where no_poliza     = a_poliza
		   and cod_cobertura = "00359"

		exit foreach;
	end foreach
else
	let _deducible_cob_b = "";
	let _limite_cob_b  = 0;
end if
----------------------------------
select count(*)
  into _cnt
  from emipocob
 where no_poliza     = a_poliza
   and cod_cobertura = "00360";	--cobertura C

if _cnt > 0 then

	foreach
		select limite_1,
		       deducible
		  into _limite_cob_c,
		       _deducible_cob_c
		  from emipocob
		 where no_poliza     = a_poliza
		   and cod_cobertura = "00360"

		exit foreach;
	end foreach
else
	let _deducible_cob_c = "";
	let _limite_cob_c  = 0;
end if
--------------------------------------
select count(*)
  into _cnt
  from emipocob
 where no_poliza     = a_poliza
   and cod_cobertura = "01064";	--Dano a la prop ajena LUC.

if _cnt > 0 then

	foreach
		select limite_1,
		       deducible
		  into _limite_cob_l,
		       _deducible_cob_l
		  from emipocob
		 where no_poliza     = a_poliza
		   and cod_cobertura = "01064"

		exit foreach;
	end foreach
else
	let _deducible_cob_l = "";
	let _limite_cob_l  = 0;
end if


	RETURN a_poliza,
		   _documento,
           _fecha_ini,
           _fecha_fin,
		   _asegurado,
		   _fecha_actual,
		   _direccion,
		   _prima_neta,
		   _impuesto,
		   _prima_bruta,
		   _limite_cob_a,
		   _deducible_cob_a,
		   _limite_cob_est,
		   _deducible_cob_est,
		   _limite_cob_equ,
		   _deducible_cob_equ,
		   _limite_maq,
		   _deducible_maq,
		   _limite_remo,
		   _deducible_remo,
		   _limite_cob_b,
		   _deducible_cob_b,
		   _limite_cob_c,
		   _deducible_cob_c,
		   _limite_cob_l,
		   _deducible_cob_l
		   WITH RESUME;   	


END PROCEDURE			   