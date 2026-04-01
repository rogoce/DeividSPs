   --Reporte Solicitado de Clientes que muestran Mala Referencia 
   --Sacar Pólizas Canceladas de cliente con Mala Referencia, con sus Polizas
   --Usuario: Henry Giron. Creado: 10/01/2019
   --execute procedure sp_pro1022('24467','2019-03','2019-03')
   DROP procedure sp_pro1022;
   CREATE procedure sp_pro1022(a_cod_cliente char(10) default '*' , a_periodo1 char(7), a_periodo2 char(7))     
   RETURNING char(20)  as no_documento,
             char(10)  as cod_cliente,
			 char(100) as nombre_cte,
			 char(50)  as mala_refencia,
			 date      as vigencia_inic,
			 date      as vigencia_final,
			 char(12)  as estatus,
			 char(30)  as tipo_cancelacion,
			 char(20)  as documento_canc,
			 dec(16,2) as saldo;

	define _cod_mala_refe   char(3);
	define _cod_tipocan     char(3);
    define _cod_cliente     char(10);
	define _no_poliza       char(10);
	define _no_documento	char(20);
	define _no_documento1	char(20);
	define _n_malarefe      char(50);
	define _n_cod_tipocan   char(30);		
	define _n_estatus       char(12);
	define _nombre_cte		char(100);
	define _estatus         smallint;
	define _fecha_modif     date;
    define _vigencia_inic	date;
	define _vigencia_final  date;
	define _saldo        	dec(16,2);
	
	
SET ISOLATION TO DIRTY READ;

--set debug file to "sp_pro1022.trc";
--trace on;

	 SELECT cod_cliente,
	        cod_mala_refe,
			nombre
	   FROM cliclien
	  WHERE mala_referencia = 1
	    and cod_cliente MATCHES a_cod_cliente
		  into temp cli_tmp; 


FOREACH
	 SELECT cod_cliente,
	        cod_mala_refe,
			nombre
	   INTO _cod_cliente,
	        _cod_mala_refe,
			_nombre_cte
	   FROM cli_tmp
		  
	    --AND cod_mala_refe in ('001') --,'005','006')
		
	let _no_documento  = null;
	let _no_documento1 = null;
    let _n_cod_tipocan = null;
    let _cod_tipocan   = null;
	let _saldo = 0;
	
	select nombre
	  into _n_malarefe
	  from climalare
	 where cod_mala_refe = _cod_mala_refe;  
	 
	foreach
	select b.no_documento,a.fecha_emision,a.cod_tipocan 
	  into _no_documento1,_fecha_modif,_cod_tipocan 
	  from endedmae a, emipomae b
	 where a.no_documento = b.no_documento
	   --and a.periodo = b.periodo 
	   --and a.periodo >= a_periodo1 and a.periodo <= a_periodo2	 
	   and a.cod_endomov = '002'                         -- CANCELACION
	   and a.cod_tipocan not in ('009','017','024')      -- PARA SER REEMPLAZADA, Por duplicidad, NO TOMADA, ¿CAMBIO DE PLAN? - no la tomo
	   and b.cod_contratante = _cod_cliente	     
	 order by a.fecha_emision desc
	  exit foreach;
	  end foreach
		  
	   if _cod_tipocan is null then
	      continue foreach;
	   end if
	   
	   if _cod_tipocan is not null then
	     SELECT trim(upper(nombre))
		   INTO	_n_cod_tipocan
		   FROM endtican
		  WHERE cod_tipocan = _cod_tipocan;
	  end if	   
	   
	foreach
	  select a.no_documento,a.no_poliza,a.cod_status,a.vigencia_inic,a.vigencia_fin, a.saldo
	    into _no_documento,_no_poliza,_estatus,_vigencia_inic,_vigencia_final, _saldo
		from emipoliza a, emipomae b
		where a.no_poliza = b.no_poliza
		and b.cod_contratante = _cod_cliente	 
		and b.actualizado = 1	 
		--and a.periodo >= a_periodo1 and a.periodo <= a_periodo2	
	   order by a.vigencia_fin desc, a.no_documento  	   	      
		
		   if _estatus = 1 then
			let _n_estatus = 'Vigente';
		   elif _estatus = 2 then
			let _n_estatus = 'Cancelada';
		   elif _estatus = 3 then
			let _n_estatus = 'Vencida';
		   else
			let _n_estatus = 'Anulada';		   
		   end if
	   
		return _no_documento, _cod_cliente, _nombre_cte,  _n_malarefe,_vigencia_inic, _vigencia_final, _n_estatus, _n_cod_tipocan, _no_documento1,_saldo with resume;
		
		 --  let _n_cod_tipocan = '';
		 --  let _cod_tipocan = '';
		   
	end foreach
end foreach	

END PROCEDURE;