-- Creacion de la Transaccion Inicial de Reclamos
-- 
-- Creado    : 04/05/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_cwf3;
CREATE PROCEDURE "informix".sp_cwf3(a_no_requis char(10), a_cod_aprobacion char(3))
returning varchar(25);

define _monto			dec(16,2);
define _monto_rec		dec(16,2);
define _monto_tr		dec(16,2);

define v_grupo			varchar(25);
define _cambio_apr_tr   varchar(20);
define _no_reclamo      char(10);
define _perd_total      smallint;
define _perd_total_t    smallint;
define _perd_total_tr   smallint;
define _cnt_col         smallint;
define _cnt_da          smallint;
define _cod_aprobacion  char(3);
define _user_added      char(8);
define _grupo_tr        varchar(25);
define _codigo_perfil   char(3);            
define _cnt_alq         smallint;
define _cod_tipotran    char(3);

let _cnt_col = 0;
let _cnt_da = 0;
let v_grupo = null;
let _cod_aprobacion = null;
let _grupo_tr = null;
let _codigo_perfil = null;
let _cnt_alq = 0;

--define _error			char(25);

--if a_no_requis = '2437052' then
--SET DEBUG FILE TO "sp_cwf3.trc"; 
--trACE ON;
--end if
SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION 
 	RETURN 'ERROR';         
END EXCEPTION           

SELECT valor_parametro 
  INTO _cambio_apr_tr 
  FROM inspaag
 WHERE codigo_compania  = '001'
   AND aplicacion       = "REC"
   AND version          = "02"
   AND codigo_parametro = "cambio_apr_tr";

IF a_cod_aprobacion = '001' THEN

	SELECT monto
	  INTO _monto
	  FROM chqchmae
	 WHERE no_requis = a_no_requis;

ELIF a_cod_aprobacion = '002' THEN
    --  Incurrido forma anterior
	--LET _monto_tr  = sp_rwf33(a_no_requis);
	--LET _monto_rec = sp_rwf34(a_no_requis);

	--LET _monto = _monto_rec + _monto_tr;
    -- ***
	-- Redifinición en los niveles de aprobación
	LET _monto  = sp_rwf170(a_no_requis);
	--***
    IF _monto < 0 THEN
		LET _monto = _monto * -1;
	END IF
	
	select user_added,
           cod_tipotran	
      into _user_added,
	       _cod_tipotran
      from rectrmae
     where no_tranrec = a_no_requis;

    select cod_aprobacion, 
	       grupo 
	  into _cod_aprobacion, 
	       _grupo_tr
	  from recajust 
	 where usuario = _user_added;	
	 
	select count(*)
	  into _cnt_col
	  from rectrcob a, prdcober b
	 where a.cod_cobertura = b.cod_cobertura
	   and a.no_tranrec = a_no_requis
	   and a.monto <> 0
	   and b.nombre like 'COLISI%';	  
	
	select count(*)
	  into _cnt_da
	  from rectrcob a, prdcober b
	 where a.cod_cobertura = b.cod_cobertura
	   and a.no_tranrec = a_no_requis
	   and a.monto <> 0
	   and b.nombre like 'DA%PROP%AJENA%';	  
	
    if _cod_tipotran = '004' then	
		select count(*)
		  into _cnt_alq
		  from rectrcob a, prdcober b
		 where a.cod_cobertura = b.cod_cobertura
		   and a.no_tranrec = a_no_requis
		   and a.monto <> 0
		   and (b.nombre like 'ENDOSO%EXTRA%PLUS%'
			or b.nombre like 'ENDOSO%TU%CHOFER%PRIVADO%' 
			or b.nombre like 'REEMBOLSO%AUTO%SUSTITUTO%'); 
	end if   
	
 -- usar el sp_rwf33  
ELIF a_cod_aprobacion = '003' OR a_cod_aprobacion = '007' THEN

	LET _monto_tr  = sp_rwf70(a_no_requis);
	LET _monto_rec = sp_rwf71(a_no_requis);

	LET _monto = _monto_rec + _monto_tr;

    IF _monto < 0 THEN
		LET _monto = _monto * -1;
	END IF
ELIF a_cod_aprobacion = '004' THEN
    --  Incurrido forma anterior
	--LET _monto_tr  = sp_rwf33(a_no_requis);
	--LET _monto_rec = sp_rwf34(a_no_requis);

	--LET _monto = _monto_rec + _monto_tr;
	-- Redifinición en los niveles de aprobación
	LET _monto  = sp_rwf170(a_no_requis);
	--***
    IF _monto < 0 THEN
		LET _monto = _monto * -1;
	END IF

	select user_added,
           cod_tipotran	
      into _user_added,
	       _cod_tipotran
      from rectrmae
     where no_tranrec = a_no_requis;

    select cod_aprobacion, 
	       grupo 
	  into _cod_aprobacion, 
	       _grupo_tr
	  from recajust 
	 where usuario = _user_added;	
	 
	select count(*)
	  into _cnt_col
	  from rectrcob a, prdcober b
	 where a.cod_cobertura = b.cod_cobertura
	   and a.no_tranrec = a_no_requis
	   and a.monto <> 0
	   and b.nombre like 'COLISI%';	  
	
	select count(*)
	  into _cnt_da
	  from rectrcob a, prdcober b
	 where a.cod_cobertura = b.cod_cobertura
	   and a.no_tranrec = a_no_requis
	   and a.monto <> 0
	   and b.nombre like 'DA%PROP%AJENA%';	  
	
    if _cod_tipotran = '004' then	
		select count(*)
		  into _cnt_alq
		  from rectrcob a, prdcober b
		 where a.cod_cobertura = b.cod_cobertura
		   and a.no_tranrec = a_no_requis
		   and a.monto <> 0
		   and (b.nombre like 'ENDOSO%EXTRA%PLUS%'
			or b.nombre like 'ENDOSO%TU%CHOFER%PRIVADO%' 
			or b.nombre like 'REEMBOLSO%AUTO%SUSTITUTO%'); 
	end if   
		
ELIF a_cod_aprobacion = '006' THEN

	LET _monto  = sp_rwf81(a_no_requis);
    
    IF _monto < 0 THEN
		LET _monto = _monto * -1;
	END IF    

ELSE

	return NULL;

END IF

let v_grupo = null;

IF _cnt_col > 0 THEN
	SELECT grupo
	  INTO v_grupo
	  FROM wf_aprodet
	 WHERE _monto         >  limite_1
	   AND _monto         <= limite_2
	   AND cod_aprobacion = '008';
END IF

IF _cnt_da > 0 THEN
	SELECT grupo
	  INTO v_grupo
	  FROM wf_aprodet
	 WHERE _monto         >  limite_1
	   AND _monto         <= limite_2
	   AND cod_aprobacion = '009';
END IF

IF _cnt_alq > 0 THEN
	SELECT grupo
	  INTO v_grupo
	  FROM wf_aprodet
	 WHERE _monto         >  limite_1
	   AND _monto         <= limite_2
	   AND cod_aprobacion = '012';
END IF

IF (_grupo_tr IS NULL OR TRIM(_grupo_tr) = "") AND v_grupo = "AJUSTADOR" THEN
	LET v_grupo = NULL;
END IF

--let a_cod_aprobacion = a_cod_aprobacion;

IF v_grupo IS NULL OR TRIM(v_grupo) = "" THEN
	SELECT grupo
	  INTO v_grupo
	  FROM wf_aprodet
	 WHERE _monto         >  limite_1
	   AND _monto         <= limite_2
	   AND cod_aprobacion = a_cod_aprobacion;
END IF   

SELECT no_reclamo
  INTO _no_reclamo
  FROM rectrmae
 WHERE no_tranrec = a_no_requis;

-- Cambio pedido por Guillermo Salas 18-09-2017
-- MODIFICAR APROBACION DE WF PARA QUE TODAS LAS TRANSACCIONES REALIZADAS DONDE SE IDENTIFIQUE QUE EL SINIESTRO ES UNA PERDIDA TOTAL LA MISMA DEBERA IR APROBACION EXCLUSIVAMENTE DEL SR. GUILLERMO SALAS 
LET _perd_total = 0;
LET _perd_total_t = 0;
LET _perd_total_tr = 0;

SELECT perd_total
  INTO _perd_total
  FROM recrcmae
 WHERE no_reclamo = _no_reclamo;

SELECT count(*)
  INTO _perd_total_t
  FROM recterce  
 WHERE no_reclamo = _no_reclamo
   AND perd_total = 1;
   
SELECT perd_total
  INTO _perd_total_tr
  FROM rectrmae
 WHERE no_tranrec = a_no_requis 
   and wf_aprobado <> 0; --> Contando todos excepto los rechazados
   
IF (_perd_total > 0 OR _perd_total_t > 0 OR _perd_total_tr = 1) AND a_cod_aprobacion not in ('006','007') THEN
	LET v_grupo = "GERENTE";
END IF

-- RE-DEFINICIÓN DE LOS NIVELES DE APROBACIÓN DE ACUERDO CON EL MONTO DE LAS TRANSACCIONES EN LA GESTIÓN DE RECLAMOS AUTOMÓVIL Y SU IMPLEMENTACION EN SISTEMA
{SELECT perd_total
  INTO _perd_total
  FROM rectrmae
 WHERE no_tranrec = a_no_requis;
 
 IF _perd_total = 1 THEN
	 SELECT count(*)
	   INTO _perd_total_tr
	   FROM rectrmae
	  WHERE no_reclamo = _no_reclamo
	    AND perd_total = 1
		AND actualizado = 1
		AND no_tranrec <> a_no_requis;
 END IF	
 
 IF _perd_total_tr IS NULL THEN
	LET _perd_total_tr = 0;
 END IF

IF _perd_total = 1 AND _perd_total_tr = 0 THEN
	LET v_grupo = "GERENTE";
END IF
}
--

IF a_cod_aprobacion IN ('002','004') AND TRIM(v_grupo) in ("TECNICO_2","GERENTE") AND trim(_cambio_apr_tr) = "1" THEN	-->Cambio pedido por OSALAZAR 1-4-2013
    SELECT monto
	  INTO _monto_tr
	  FROM rectrmae
	 WHERE no_tranrec = a_no_requis;

	IF  _monto_tr <= 1000 THEN
		SELECT grupo
		  INTO v_grupo
		  FROM wf_aprodet
		 WHERE 10         >  limite_1
		   AND 10         <= limite_2
		   AND cod_aprobacion = a_cod_aprobacion;
	END IF
END IF 

-- Mientras llegue el reemplazo de la Dra. Cesar caso # 6662--
-- Ya llegó el reemplazo Amado 20-06-2023 caso # 6894 --
{If a_cod_aprobacion = '006' and _monto > 5000 then
	select user_added  
      into _user_added
      from rectrmae
     where no_tranrec = a_no_requis;
     
    select codigo_perfil
      into _codigo_perfil
      from insuser
     where usuario = _user_added;
     
    if _codigo_perfil = '177' then --Aprueba Efren else aprueba Edgardo
		SELECT grupo
		  INTO v_grupo
		  FROM wf_aprodet
		 WHERE 5000         >  limite_1
		   AND 5000         <= limite_2
		   AND cod_aprobacion = a_cod_aprobacion;
    else  
		SELECT grupo
		  INTO v_grupo
		  FROM wf_aprodet
		 WHERE 5001         >  limite_1
		   AND 5001         <= limite_2
		   AND cod_aprobacion = a_cod_aprobacion;
    end if   
End if
}
return trim(v_grupo);	
END
end procedure
