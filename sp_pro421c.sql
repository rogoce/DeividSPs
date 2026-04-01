-- f_emision_cesion_fac
-- Creado    : 16/06/2021 - Autor: Amado Perez
 

DROP PROCEDURE sp_pro421c;
CREATE PROCEDURE sp_pro421c(a_poliza char(10), a_endoso CHAR(5)) 
RETURNING INTEGER, VARCHAR(50);		   

DEFINE ls_tmp		CHAR(10);
DEFINE _error   	SMALLINT;
DEFINE ls_contrato	CHAR(5);
DEFINE ls_coasegur	CHAR(3);

SET ISOLATION TO DIRTY READ;
--  set debug file to "sp_che117.trc";	
--  trace on;

LET _error = 0;

FOREACH
	SELECT cod_contrato,
	       cod_coasegur
	  INTO ls_contrato,
	       ls_coasegur
	  FROM emifafac
     WHERE no_poliza = a_poliza
       AND no_endoso = a_endoso
       AND no_cesion IS NULL OR TRIM(no_cesion) = ""
  GROUP BY cod_contrato, cod_coasegur
  ORDER BY cod_coasegur

	let ls_tmp =  sp_sis13 ("001", 'PRO', '02', 'par_cesion');

	If ls_tmp Is Null Or trim(ls_tmp) = "" Then
		LET _error = 1;
		EXIT FOREACH;
	End If
      
    UPDATE emifafac
       SET no_cesion = ls_tmp
     WHERE no_poliza = a_poliza
       AND no_endoso = a_endoso
	   AND cod_contrato = ls_contrato
	   AND cod_coasegur = ls_coasegur;
END FOREACH

If _error = 1 Then
	Return 42, "Bloqueo par_cesion";
End If

Return 0, "Exito";

END PROCEDURE	  