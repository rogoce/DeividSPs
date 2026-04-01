-- POLIZAS VIGENTES 
--

DROP procedure sp_jean02;
CREATE procedure sp_jean02(a_fecha date)
RETURNING date,char(20),CHAR(5),char(10),char(50),char(10),CHAR(50),REFERENCES TEXT;

DEFINE _no_poliza	 	CHAR(10);
DEFINE _no_documento    CHAR(20);
DEFINE _cod_contratante char(10);
DEFINE _n_contratante,_n_producto  	CHAR(50);
DEFINE _cnt  			integer;
DEFINE _cod_producto    char(10);
DEFINE lblb_descripcion REFERENCES TEXT;
define v_filtros        varchar(255);
define _no_unidad       char(5);
define _vigencia_inic   date;
define _cod_no_renov    char(3);

CALL sp_pro03("001","001",a_fecha,"002;") RETURNING v_filtros;

foreach
	select no_poliza,
	       no_documento,
		   cod_contratante
	  into _no_poliza,
	       _no_documento,
		   _cod_contratante
	  from temp_perfil
	 where seleccionado = 1
	   and cod_subramo in('002','005','012')
	   
	select vigencia_inic,
	       cod_no_renov
	  into _vigencia_inic,
	       _cod_no_renov
	  from emipomae
     where no_poliza = _no_poliza;

    if _cod_no_renov = '039' then
		continue foreach;
    end if	
	   
	select count(*)
	  into _cnt
	  from emipocob
	 where no_poliza = _no_poliza
	   and cod_cobertura in('01030','01141','00907');
	   
	if _cnt is null then
		let _cnt = 0;
	end if
    if _cnt > 0 then
		continue foreach;
	end if

	select nombre
	  into _n_contratante
	  from cliclien
	 where cod_cliente = _cod_contratante;
	
	foreach
		select no_unidad,
		       cod_producto
	      into _no_unidad,
		       _cod_producto
 	      from emipouni 
		 where no_poliza = _no_poliza
		
		select nombre
		  into _n_producto
		  from prdprod
		 where cod_producto = _cod_producto;
		 
		call sp_blob_emipode2(_no_poliza ,_no_unidad) returning lblb_descripcion;
		
		return _vigencia_inic,_no_documento,_no_unidad,_cod_contratante,_n_contratante,_cod_producto,_n_producto,lblb_descripcion with resume;
		
	end foreach	
		 
end foreach
END PROCEDURE;
