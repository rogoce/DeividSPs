-- Procedimiento que carga los Saldos de las polizas por reaseguro
-- 25/11/2009 - Autor: Amado Perez.
-- 15/10/2010 - Modificado - Autor: Henry: Cambio del sp_sis21 a utilizar poliza a la fecha, por orden de Sr. Naranjo 
-- 10/04/2011 - Modificado - Autor: Henry: Arlena Gomez , tomar la parte de terremoto no se estaba calculando.
-- execute procedure sp_rea24("001","001","2010-12")

drop procedure sp_rea24;
create procedure "informix".sp_rea24(a_compania CHAR(3), a_sucursal CHAR(3), a_periodo CHAR(7))
returning integer,
          char(50);

define _error			   		integer;
define _descripcion        	char(50);
define _fecha              	date;
define _cod_coasegur       	char(3);
define _no_poliza		   		char(10);
define _no_poliza_1        	char(10);
define _saldo_act          	dec(16,2);
define _saldo_ant          	dec(16,2);
define _porc_partic_prima  	dec(9,2);
define _porc_partic_reas   	dec(9,6);
define _saldo_reaseg       	dec(16,2);
define _comision      	   		dec(16,2);
define _impuesto           	dec(16,2);
define _doc_poliza         	char(20);     
define _cod_ramo           	char(3);
define _cod_contratante    	char(10);
define _vigencia_inic      	date;
define _vigencia_final     	date;
define _nombre             	varchar(50);
define _nombre_reas        	varchar(50);
define _nombre_contratante	varchar(100);
define _periodo            	varchar(7);
define _debito             	dec(16,2);
define _credito            	dec(16,2);
define _debito_final       	dec(16,2);
define _credito_final      	dec(16,2);
define _monto_tran         	dec(16,2); 
define _diferencia_saldo   	dec(16,2);
define _suma_total         	dec(16,2);
define _mes					smallint;
define _ano    	     		smallint;
define _no_registro     		char(10);
define _cod_auxiliar			char(5);
define _cantidad				smallint;

delete from rea_saldo
where periodo = a_periodo;

call sp_rea24b(a_compania, a_sucursal,a_periodo, a_periodo) returning _error, _descripcion;

if _error <> 0 then
	return _error, _descripcion;
end if

--SET DEBUG FILE TO "sp_rea24.trc";
--TRACE ON ;

let _diferencia_saldo	= 0;
let _saldo_ant        	= 0;
let _credito_final    	= 0;
let _debito_final     	= 0;

foreach
 select cod_auxiliar,
        debito,
		credito,
		r.no_documento
   into _cod_auxiliar,
        _debito,
		_credito,
		_doc_poliza
   from sac999:reacomp r, sac999:reacompasiau a
  where r.no_registro	= a.no_registro
    and a.periodo     	= a_periodo
	and cuenta        	= '2550101'

	--	and r.no_documento = '0112-00444-01'

	if _credito is null then
		let _credito = 0.00;	
	end if 
	
	if _debito is null then
		let _debito = 0.00;	
	end if 
	
	if _credito > 0 then
		let _credito = _credito * -1;
	end if

	let _monto_tran = _debito + _credito;

    select cod_coasegur
	  into _cod_coasegur
	  from emicoase
	 where aux_bouquet = _cod_auxiliar;
	
	if _cod_coasegur is null then
		let _cod_coasegur = "036";
	end if

	select count(*)
	  into _cantidad
	  from rea_saldo
     where no_documento	= _doc_poliza
	   and cod_coasegur 	= _cod_coasegur
	   and periodo      	= a_periodo;

	if _cantidad = 0 then

		let _no_poliza = sp_sis21(_doc_poliza);

		select cod_ramo,
			   cod_contratante,
			   vigencia_inic,
			   vigencia_final
		  into _cod_ramo,
			   _cod_contratante,
			   _vigencia_inic,
			   _vigencia_final
		  from emipomae
		 where no_poliza = _no_poliza;
		
		insert into rea_saldo(
			cod_coasegur,	
			no_poliza,     
			saldo_tot, 
			saldo_ant,
			porc_partic_cont,
			porc_partic_reas,
			comision, 
			impuesto, 
			no_documento,   
			cod_ramo,      
			cod_contratante,
			vigencia_inic,	
			vigencia_final,
			es_terremoto,
			porc_com_reas,
			periodo,
			saldo_coasegur,
			monto_tran
			)
			values(
			_cod_coasegur,
			_no_poliza,
			0,
			0,
			0,
			0,
			0,
			0,
			_doc_poliza,
			_cod_ramo,
			_cod_contratante,
			_vigencia_inic,
			_vigencia_final,
			0,
			0,
			a_periodo,
			0,
			_monto_tran
			);

	else

		update rea_saldo
		   set monto_tran  	=  monto_tran + _monto_tran
		 where no_documento	= _doc_poliza
		   and cod_coasegur 	= _cod_coasegur
		   and periodo      	= a_periodo;
						
	end if						
			
end foreach

return 0, "Actualizacion Exitosa";

end procedure