-- Consulta de Transacciones por requisicion

-- Creado    : 25/06/2004 - Autor: Amado Perez M.
-- Modificado: 25/06/2004 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE ap_ajust_wf2;

CREATE PROCEDURE ap_ajust_wf2(a_periodo CHAR(7))
RETURNING char(10) as No_Tramite,
          char(20) as Reclamo,
		  char(10) as SP,
          char(3) as Cod_Ajustador,
          char(8) as Ajustador,
          date as Fecha_Reclamo,
          char(3) as Cod_Sucursal,
          char(10) as Asigna,
          varchar(50) as Descripcion;

define _no_reclamo 			char(10);
define _numrecla            char(20);
define _no_poliza           char(10);
define _cod_cobertura       char(5);
define _tipo_cob            char(1);
define _cont_c              smallint;
define _cont_r              smallint;
define _tipo_asis           char(1);
define _sp                  char(10);
define _cod_ajustador       char(3);
define _ajustador           char(8);
define _fecha_reclamo, _fecha1, _fecha2 date;
define _cod_sucursal        char(3);
define _asigna              char(10);
define _descripcion         varchar(50);
define _mes1, _mes2, _ano1, _ano2   SMALLINT;
define _no_tramite          char(10);

--set debug file to "sp_rwf02.trc";

SET ISOLATION TO DIRTY READ;

FOREACH
    SELECT no_reclamo,
           numrecla,
           no_poliza,
           ajust_interno,
           fecha_reclamo,
           cod_sucursal,
		   no_tramite
	  INTO _no_reclamo,
           _numrecla,
           _no_poliza,
           _cod_ajustador,
           _fecha_reclamo,
           _cod_sucursal,
		   _no_tramite
	  FROM recrcmae
	 WHERE periodo = a_periodo
       AND numrecla[1,2] in ('02','20','23')
       AND actualizado = 1
	   AND fecha_reclamo >= '14-03-2024'
  ORDER BY 5, 7
  
    SELECT usuario
	  INTO _ajustador
	  FROM recajust
     WHERE cod_ajustador = _cod_ajustador;

 {  LET _cont_c = 0;
   LET _cont_r = 0; 
  
    FOREACH
        SELECT cod_cobertura
          INTO _cod_cobertura
          FROM rectrcob a, rectrmae b
         WHERE a.no_tranrec = b.no_tranrec
		   AND b.no_reclamo = _no_reclamo
		   AND b.cod_tipotran = '001'
         
         LET _tipo_cob = sp_rwf179(_no_poliza, _cod_cobertura);
                  
         IF _tipo_cob = 'C' THEN
            LET _cont_c = _cont_c + 1;
         ELIF _tipo_cob = 'R' THEN 
            LET _cont_r = _cont_r + 1; 
         END IF
    END FOREACH
    
    LET _descripcion = null;
    
    IF _cont_r > 0 THEN
        LET _tipo_asis = 'R';
        LET _sp = 'sp_rwf180';
        LET _asigna = 'EQUI. TERC';
    ELSE }
        LET _tipo_asis = 'C';    
        LET _sp = 'sp_rwf86';  
        call ap_rwf86b(_cod_sucursal, _no_poliza) returning _asigna, _descripcion;  
  --  END IF
	RETURN _no_tramite,
	       _numrecla, 
		   _sp,
           _cod_ajustador,
           _ajustador,
           _fecha_reclamo,
           _cod_sucursal,
           _asigna,
           _descripcion
	 	   WITH RESUME;

END FOREACH

-- Descomponer los periodos en fechas
LET _ano1 = a_periodo[1,4];
LET _mes1 = a_periodo[6,7];

LET _fecha1 = MDY(_mes1,1,_ano1);

LET _fecha1 = '14-03-2024';

LET _ano2 = a_periodo[1,4];
LET _mes2 = a_periodo[6,7];

IF _mes2 = 12 THEN
   LET _mes2 = 1;
   LET _ano2 = _ano2 + 1;
ELSE
   LET _mes2 = _mes2 + 1;
END IF
LET _fecha2 = MDY(_mes2,1,_ano2);
LET _fecha2 = _fecha2 - 1;

FOREACH
    SELECT a.no_reclamo,
           a.user_changed,
           a.date_added
	  INTO _no_reclamo,
           _cod_ajustador,
           _fecha_reclamo
 	  FROM recterce a
	 WHERE a.date_added >= _fecha1
       AND a.date_added <= _fecha2
  ORDER BY 3, a.no_incidente

    SELECT numrecla,
           no_poliza,
           cod_sucursal,
		   no_tramite
      INTO _numrecla,
           _no_poliza,
           _cod_sucursal,
		   _no_tramite
      FROM recrcmae
     WHERE no_reclamo = _no_reclamo;

{   LET _cont_c = 0;
   LET _cont_r = 0; 

    FOREACH
        SELECT cod_cobertura
          INTO _cod_cobertura
          FROM recrccob
         WHERE no_reclamo = _no_reclamo
         
         LET _tipo_cob = sp_rwf179(_no_poliza, _cod_cobertura);
                  
         IF _tipo_cob = 'C' THEN
            LET _cont_c = _cont_c + 1;
         ELIF _tipo_cob = 'R' THEN 
            LET _cont_r = _cont_r + 1; 
         END IF
    END FOREACH
}
    SELECT usuario
	  INTO _ajustador
	  FROM recajust
     WHERE cod_ajustador = _cod_ajustador;

--   IF _cont_r > 0 THEN
--        LET _asigna = 'AJUS. RECL';
--    ELSE 
        LET _asigna = 'EQUI. TERC';
--    END IF
     
	RETURN _no_tramite,
	       _numrecla, 
		   'sp_rwf103',
           _cod_ajustador,
           _ajustador,
           _fecha_reclamo,
           _cod_sucursal,
           _asigna,
           NULL
	 	   WITH RESUME;
     
END FOREACH
END PROCEDURE;
