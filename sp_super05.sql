   --Reporte Solicitado por Leyri Moreno para auditoria solicitado por Henry Machado.
   --Sacar pólizas vigentes
   --  Armando Moreno M. 24/03/2017
   
   DROP procedure sp_super05;
   CREATE procedure sp_super05()
   RETURNING char(20),char(10),char(100),date,char(50),date,date;

	DEFINE _cod_mala_refe     		 CHAR(3);
    DEFINE _cod_cliente,_no_poliza   CHAR(10);
    DEFINE _fecha_modif       		 date;
	define _no_documento	char(20);
	define _n_malarefe      char(50);
	define _nombre_cte		char(100);
	define _estatus         smallint;
    define _vigencia_inic	date;
	define _vigencia_final  date;
	
SET ISOLATION TO DIRTY READ;

FOREACH
	 SELECT cod_cliente,
	        cod_mala_refe,
			nombre
	   INTO _cod_cliente,
	        _cod_mala_refe,
			_nombre_cte
	   FROM cliclien
	  WHERE mala_referencia = 1
	    AND cod_mala_refe in('001','005','006')
		
	let _no_documento = null;
	
	select nombre
	  into _n_malarefe
	  from climalare
	 where cod_mala_refe = _cod_mala_refe;
	 
	foreach
	  select no_documento
	    into _no_documento
		from emipomae
	   where cod_contratante = _cod_cliente
		 and actualizado = 1
		 and periodo >= '2016-01'
		 and periodo <= '2017-03'
	   group by no_documento
	   order by no_documento

	   let _no_poliza = sp_sis21(_no_documento) ;
	   select estatus_poliza,
			  vigencia_inic,
			  vigencia_final
		 into _estatus,
              _vigencia_inic,
			  _vigencia_final
		 from emipomae
        where no_poliza = _no_poliza;
		
	   if _no_documento is null then
		 continue foreach;
	   end if
	   if _estatus = 1 then
	   else
			continue foreach;
	   end if	
	   let _fecha_modif = null;
	
		select first 1 date(fecha_modif)
		  into _fecha_modif
		  from clibitacora
		 where cod_cliente     = _cod_cliente
		   and mala_referencia = 1;
	   
		return _no_documento, _cod_cliente, _nombre_cte, _fecha_modif, _n_malarefe,_vigencia_inic, _vigencia_final with resume;
	end foreach
end foreach	

END PROCEDURE;