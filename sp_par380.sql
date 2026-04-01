-- Procedimiento para buscar clientes con registro en ponderación
--
-- creado: 22/06/2023 - Autor: Amado Perez M.

DROP PROCEDURE sp_par380;
CREATE PROCEDURE sp_par380(a_cod_cliente CHAR(10), a_fecha_susc DATE, a_cod_sucursal CHAR(3))
	RETURNING 	  SMALLINT,
                  CHAR(30),
                  VARCHAR(100),
                  DEC(5,2);  

DEFINE _cedula             CHAR(30);
DEFINE _nombre             VARCHAR(100);
DEFINE _valor_ponderacion  DEC(5,2);
DEFINE _cnt_aum_salud		SMALLINT;
DEFINE _cnt                SMALLINT;
DEFINE _cod_riesgo         INTEGER;
DEFINE _date_add, _date_changed, _date_compara DATE;
DEFINE _agno               SMALLINT;
DEFINE li_digitalizado     smallint;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_par380.trc";
--TRACE ON;


let _cnt = 0;
let li_digitalizado = 0;
	

SELECT cedula,
       nombre
  INTO _cedula,
       _nombre
  FROM cliclien      
 WHERE cod_cliente = a_cod_cliente;
 
select count(*)
  into _cnt_aum_salud
  from deivid_tmp:salud_ren_rec
 where codasegurado = a_cod_cliente;

if _cnt_aum_salud is null then	
	let _cnt_aum_salud = 0;
end if

if _cnt_aum_salud > 0 then
	RETURN 1, _cedula, _nombre, 0.00;
Else
	select count(*)
	  into _cnt_aum_salud
	  from deivid_tmp:salud_ren_cli
	 where cod_contratante = a_cod_cliente;
	 
	if _cnt_aum_salud is null then	
		let _cnt_aum_salud = 0;
	end if
	
	if _cnt_aum_salud > 0 then
		RETURN 1, _cedula, _nombre, 0.00;
	end if	
End If
 
IF a_cod_sucursal IN ('047','083','090') THEN
	RETURN 1, _cedula, _nombre, 0.00; 
END IF

IF a_cod_cliente IN ('878430','878014','878431','08630','02611','153447','159455','92597') THEN
	RETURN 1, _cedula, _nombre, 0.00; 
END IF

SELECT COUNT(*)
  INTO _cnt
  FROM ponderacion
 WHERE cod_cliente = a_cod_cliente;
 
IF _cnt IS NULL THEN
    let _cnt = 0;
END IF

IF _cnt = 0 THEN
    RETURN _cnt, _cedula, _nombre, 0.00; 
END IF    

-- # 7255 FCORONADO 09/08/2023 Se agrego validacion del campo digitalizado que se marca cuando los clientes tienen los documentos guardados.
SELECT digitalizado,valor_ponderacion
  INTO li_digitalizado, _valor_ponderacion
  FROM ponderacion
 WHERE cod_cliente = a_cod_cliente;

IF li_digitalizado = 0 THEN
    RETURN 0, _cedula, _nombre, _valor_ponderacion; 
END IF 

SELECT valor_ponderacion,
       cod_riesgo,
       date_add,
       date_changed
  INTO _valor_ponderacion,
       _cod_riesgo,
       _date_add,
       _date_changed
  FROM ponderacion
 WHERE cod_cliente = a_cod_cliente;
 
IF _date_changed > _date_add THEN
    let _date_compara = _date_changed;
ELSE
    let _date_compara = _date_add;
END IF    

LET _agno = sp_sis78(_date_compara, a_fecha_susc);   

IF _cod_riesgo = 0 THEN
    RETURN 0, _cedula, _nombre, _valor_ponderacion;
ELIF _cod_riesgo = 3 THEN  -- Riesgo Bajo
    IF _agno >= 5 THEN
        RETURN 0, _cedula, _nombre, _valor_ponderacion;
    END IF
ELIF _cod_riesgo = 2 THEN  -- Riesgo Mediano       
    IF _agno >= 2 THEN
        RETURN 0, _cedula, _nombre, _valor_ponderacion;
    END IF
ELIF _cod_riesgo = 1 THEN  -- Riesgo Alto       
    IF _agno >= 1 THEN
        RETURN 0, _cedula, _nombre, _valor_ponderacion;
    END IF
END IF
RETURN _cnt, _cedula, _nombre, _valor_ponderacion; 
END PROCEDURE
