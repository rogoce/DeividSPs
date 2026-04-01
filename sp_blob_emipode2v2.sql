-- Procedimiento que Genera el txt 
-- Creado : 14/09/2016 - Autor: Henry Giron 
DROP PROCEDURE sp_blob_emipode2v2;

CREATE PROCEDURE sp_blob_emipode2v2(ls_poliza CHAR(10), ls_unidad CHAR(5))
RETURNING REFERENCES TEXT as descripcion,
char(10)						as poliza,
char(5)						as unidad;

DEFINE v_descripcion REFERENCES TEXT;
DEFINE _no_poliza char(10);
DEFINE _no_unidad char(5);

foreach
	select emi.no_poliza,
		    uni.no_unidad
	  into _no_poliza,
		    _no_unidad
	  from emipomae emi
	  inner join emipouni uni on uni.no_poliza = emi.no_poliza
	  where emi.estatus_poliza = 1
	    and emi.cod_ramo in ('001','003')
		and emi.actualizado = 1

	call sp_blob_emipode2(_no_poliza,_no_unidad) returning v_descripcion;
	
	--insert into deivid_tmp:tmp_emipode2
	--values(_no_poliza,_no_unidad,v_descripcion);
	return v_descripcion,_no_poliza,_no_unidad with resume;
end foreach
END PROCEDURE;