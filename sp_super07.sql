   --Reporte Solicitado por Leyri Moreno para auditoria solicitado por Henry Machado.
   --Sacar pólizas vigentes
   --  Armando Moreno M. 24/03/2017
   
   DROP procedure sp_super07;
   CREATE procedure sp_super07()
   RETURNING char(20),char(10),char(100),char(50),char(5),char(50),decimal(16,2),decimal(16,2),decimal(16,2);

   	DEFINE _no_unidad     		 CHAR(5);
    DEFINE _cod_contratante,_no_poliza   CHAR(10);
	define _no_documento	char(20);
	define _n_nombre_subramo      char(50);
	define _n_nombre		char(100);
	define _fecha 			date;
	define _cod_subramo,_cod_sucursal     char(3);
	define v_filtros        varchar(255);
	define _n_nombre_suc    char(50);
	define _suma_asegurada,_prima_neta,_porc  decimal(16,2);
	
SET ISOLATION TO DIRTY READ;

let _fecha          = current;
let _n_nombre_suc   = null;
let _suma_asegurada = 0;
let _porc = 0;
CALL sp_pro03('001','001',_fecha,'009;') RETURNING v_filtros;  --temp_perfil

FOREACH
	 SELECT no_poliza,
	        no_documento,
			cod_contratante,
			cod_subramo,
			cod_sucursal,
			suma_asegurada
	   INTO _no_poliza,
	        _no_documento,
			_cod_contratante,
			_cod_subramo,
			_cod_sucursal,
			_suma_asegurada
	   FROM temp_perfil
	  WHERE seleccionado = 1
	    AND cod_subramo in('001','002')
		
	select descripcion
	  into _n_nombre_suc
	  from insagen
	 where codigo_agencia = _cod_sucursal;
	
	select nombre
	  into _n_nombre
	  from cliclien
	 where cod_cliente = _cod_contratante;
	 
	select nombre
	  into _n_nombre_subramo
	  from prdsubra
	 where cod_ramo = '009'
	   and cod_subramo = _cod_subramo;
	   
	let _prima_neta = 0;
	let _porc       = 0;
    select prima_neta into _prima_neta from emipomae where no_poliza = _no_poliza;
	if _suma_asegurada = 0 then
		let _porc = 0;
	else
		let _porc = (_prima_neta/_suma_asegurada) * 100;
	end if	

	foreach
	  select no_unidad
	    into _no_unidad
		from emipouni
	   where no_poliza = _no_poliza

		return _no_documento, _cod_contratante, _n_nombre, _n_nombre_subramo, _no_unidad,_n_nombre_suc,_prima_neta,_suma_asegurada,_porc with resume;
		
	end foreach
end foreach	
drop table temp_perfil;
END PROCEDURE;