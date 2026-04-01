   --Reporte Solicitado por Leyri Moreno para auditoria solicitado por Henry Machado.
   --Sacar pólizas vigentes
   --  Armando Moreno M. 24/03/2017
   
   DROP procedure sp_super06;
   CREATE procedure sp_super06()
   RETURNING char(12),char(20),char(10),char(100),date,char(50),date,date,char(50),date;

	DEFINE _cod_mala_refe     		 CHAR(3);
    DEFINE _cod_cliente,_no_poliza   CHAR(10);
    DEFINE _fecha_modif       		 date;
	define _no_documento	char(20);
	define _n_malarefe      char(50);
	define _nombre_cte		char(100);
	define _estatus,_cnt    smallint;
    define _vigencia_inic	date;
	define _vigencia_final  date;
	define _n_estatus       char(12);
	define _fecha 			date;
	define _n_formapag      char(50);
	define _cod_formapag    char(3);
	
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

	let _no_documento = null;
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

	   if _no_documento is null then
		 continue foreach;
	   end if

	   let _no_poliza = sp_sis21(_no_documento);
	   select count(*)
	     into _cnt
		 from coboutleg
		where no_documento = _no_documento;
       if _cnt is null then
			let _cnt = 0;
	   end if

	   let _fecha     = null;
	   
	   if _cnt > 0 then
			foreach
				select fecha
				  into _fecha
				  from coboutleg
				 where no_documento = _no_documento
				exit foreach;
			end foreach
	   else
		   select count(*)
			 into _cnt
			 from coboutlegh
			where no_documento = _no_documento;
		   if _cnt is null then
				let _cnt = 0;
		   end if
		   if _cnt > 0 then
			foreach
				select fecha
				  into _fecha
				  from coboutlegh
				 where no_documento = _no_documento
				exit foreach;
			end foreach
		   end if	
	   end if

	   select estatus_poliza,
			  vigencia_inic,
			  vigencia_final,
			  cod_formapag
		 into _estatus,
              _vigencia_inic,
			  _vigencia_final,
			  _cod_formapag
		 from emipomae
        where no_poliza = _no_poliza;
		
		let _n_formapag = "";
		select nombre into _n_formapag from cobforpa where cod_formapag = _cod_formapag;
		
	   if _estatus = 1 then
		let _n_estatus = 'Vigente';
	   elif _estatus = 2 then
		let _n_estatus = 'Cancelada';
	   elif _estatus = 3 then
		let _n_estatus = 'Vencida';
	   else
		let _n_estatus = 'Anulada';		   
	   end if
	   let _fecha_modif = null;
	
		select first 1 date(fecha_modif)
		  into _fecha_modif
		  from clibitacora
		 where cod_cliente     = _cod_cliente
		   and mala_referencia = 1;
	   
		return _n_estatus, _no_documento, _cod_cliente, _nombre_cte, _fecha_modif, _n_malarefe,_vigencia_inic, _vigencia_final,_n_formapag,_fecha with resume;
	end foreach
end foreach	

END PROCEDURE;