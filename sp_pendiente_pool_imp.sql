-- pool impresion de renovacion automatica
-- Creado		: 18/05/2009	- Autor: Henry Giron.
-- Modifciado	: 07/02/2012	- Autor: Roman Gordon	**Se Agrego al acreedor para aplicarlo al ordenamiento del datawindow

drop procedure sp_pendiente_pool_imp;

create procedure "informix".sp_pendiente_pool_imp(a_estatus smallint)
returning varchar(50),		--_n_corredor,
		  char(8),			--_user_added,   
		  char(20),			--_no_documento,   
		  date,				--_vigencia_inic,   
		  date,				--_vigencia_final,      
		  char(10),			--_no_factura,   
		  varchar(100),		--_n_cliente,
		  varchar(15),			--_estatus
		  varchar(15),
		  varchar(50),			--_cod_sucursal
		  varchar(50);		--_nom_acreedor

define _n_cliente       	varchar(100);
define _n_corredor      	varchar(50);
define _nom_acreedor		varchar(50);
define _n_sucursal			varchar(50);
define _status_imp			varchar(15);
define _status_pol			varchar(15);
define _no_documento		char(20);
define _no_poliza	    	char(10);
define _no_factura			char(10);
define _no_poliza2      	char(10);	 
define _cod_contratante 	char(10);	 
define _user_added   		char(8);
define _cod_agente  		char(5);
define _cod_acreedor		char(5);
define _fil_suc				char(3);
define _cod_depto			char(3);
define _sucursal        	char(3);
define _cod_ramo        	char(3);
define _suc_prom        	char(3);
define _cod_sucursal  		char(3);
define _cod_no_renov   		char(3);
define _tipo				char(1);
define _saldo				dec(16,2);
define _incurrido			dec(16,2);
define _pagos   			dec(16,2);
define _porc_depreciacion	dec(5,2);
define _status_poliza		smallint;
define _renovar   			smallint;
define _estatus         	smallint;
define _no_renovar			smallint;
define _cant_reclamos		smallint;
define _saldo_porc      	integer;
define _fecha_selec			date;
define _vigencia_inic		date;
define _vigencia_final		date;

set isolation to dirty read;

--set debug file to "sp_pro856.trc";
--trace on;
	
{if a_sucursal in ('*','*;') then	

	if a_sucursal = '*;' then
		let a_sucursal = '001';
	else
		let a_sucursal = '';--'006';
	end if
	
	foreach
		select codigo_agencia
		  into _cod_sucursal
		  from insagen  
		 where sucursal_promotoria <> '001'
		
		if a_sucursal = '' or a_sucursal is null then
			let a_sucursal = trim(a_sucursal) || trim(_cod_sucursal);
		else
			let a_sucursal = trim(a_sucursal) || ',' || trim(_cod_sucursal);
		end if
	end foreach
	
	let a_sucursal = trim(a_sucursal) || ';';	
	let _tipo = sp_sis04(a_sucursal); -- Separa los valores del String
else
	let _tipo = sp_sis04(a_sucursal); -- Separa los valores del String
end if}

foreach
	select no_poliza,   
           user_added,   
           cod_no_renov,   
           no_documento,   
           renovar,   
           no_renovar,   
           fecha_selec,   
           vigencia_inic,   
           vigencia_final,   
           saldo,   
           cant_reclamos,   
           no_factura,   
           incurrido,   
           pagos,   
           porc_depreciacion,   
           cod_agente,
           estatus,
           cod_sucursal  
	  into _no_poliza,
		   _user_added,   
		   _cod_no_renov,   
		   _no_documento,   
		   _renovar,   
		   _no_renovar,   
		   _fecha_selec,   
		   _vigencia_inic,   
		   _vigencia_final,   
		   _saldo,   
		   _cant_reclamos,   
		   _no_factura,   
		   _incurrido,   
		   _pagos,   
		   _porc_depreciacion,
		   _cod_agente,
           _estatus,
           _cod_sucursal  		   
      from emirepo  
     where estatus   in ( a_estatus,9)
	 order by cod_sucursal

	if _estatus = 5 then
		let _status_imp = 'Por Imprimir';
	elif _estatus = 9 then
		let _status_imp = 'ReImprimir';
	end if
	 
	let _no_poliza2 = sp_sis21(_no_documento);
	
	select cod_contratante,
           vigencia_inic,
		   vigencia_final,
		   sucursal_origen,
		   cod_ramo,
		   estatus_poliza
  	  into _cod_contratante,
	       _vigencia_inic,
		   _vigencia_final,
		   _sucursal,
		   _cod_ramo,
		   _status_poliza
  	  from emipomae
     where no_poliza = _no_poliza2;
	
	let _cod_acreedor = '';
	let _nom_acreedor = ''; 
	
	if _status_poliza = 1 then
		let _status_pol = 'Vigente';
	elif _status_poliza = 2 then
		let _status_pol = 'Cancelada';
	elif _status_poliza = 3 then
		let _status_pol = 'Vencida';
	end if
	
	foreach
		select cod_acreedor
		  into _cod_acreedor
		  from emipoacr
		 where no_poliza = _no_poliza2

		select nombre
		  into _nom_acreedor
		  from emiacre
		 where cod_acreedor = _cod_acreedor;

		exit foreach;
	end foreach
	
	if _cod_acreedor is null then
		let _cod_acreedor = '';
	end if
	
	select sucursal_promotoria
	  into _suc_prom
	  from insagen
	 where codigo_agencia  = _sucursal
	   and codigo_compania = '001';
	   
	select descripcion
	  into _n_sucursal
	  from insagen
	 where codigo_agencia = _suc_prom
	   and codigo_compania = '001';
	
	{if _cod_ramo <> "008" then  --fianzas si se imprime en casa matriza siempre.
		if _suc_prom not in (select codigo from tmp_codigos) then 
			continue foreach;
		end if
	end if}

	select nombre
	  into _n_cliente
	  from cliclien
	 where cod_cliente = _cod_contratante;

	select nombre
 	  into _n_corredor
	  from agtagent
	 where cod_agente = _cod_agente;

	return _n_corredor,
   		   _user_added,     
		   _no_documento,     
		   _vigencia_inic,   
		   _vigencia_final,   
		   _no_factura,   
		   _n_cliente,
		   _status_pol,
		   _status_imp,
		   _n_sucursal,
		   _nom_acreedor
		   with resume;
end foreach
--drop table tmp_codigos;
end procedure	