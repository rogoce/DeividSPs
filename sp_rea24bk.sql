-- Procedimiento que carga los Saldos de las polizas por reaseguro
-- 25/11/2009 - Autor: Amado Perez.
-- 15/10/2010 - Modificado - Autor: Henry: Cambio del sp_sis21 a utilizar poliza a la fecha, por orden de Sr. Naranjo 
-- 10/04/2011 - Modificado - Autor: Henry: Arlena Gomez , tomar la parte de terremoto no se estaba calculando.
-- execute procedure sp_rea24("001","001","2010-12")

drop procedure sp_rea24bk;
create procedure "informix".sp_rea24bk(a_compania CHAR(3), a_sucursal CHAR(3), a_periodo CHAR(7))
returning integer,
          char(50);

{
returning CHAR(3),                  
		  varchar(50),                              
		  char(20),                 
		  DEC(16,2),               
		  DEC(16,2),               
		  DEC(16,2),               
		  DEC(16,2),               
		  CHAR(7),
		  char(3),
		  char(50);                 
}		  
define _error			   integer;
define _descripcion        char(50);
define _fecha              date;
define _cod_coasegur       char(3);
define _no_poliza		   char(10);
define _no_poliza_1        char(10);
define _saldo_act          DEC(16,2);
define _saldo_ant          DEC(16,2);
define _porc_partic_prima  DEC(9,2);
define _porc_partic_reas   DEC(9,6);
define _saldo_reaseg       DEC(16,2);
define _comision      	   DEC(16,2);
define _impuesto           DEC(16,2);
define _doc_poliza         char(20);     
define _cod_ramo           char(3);
define _cod_contratante    char(10);
define _vigencia_inic      date;
define _vigencia_final     date;
define _nombre             varchar(50);
define _nombre_reas        varchar(50);
define _nombre_contratante varchar(100);
define _periodo            varchar(7);
define _debito             DEC(16,2);
define _credito            DEC(16,2);
define _debito_final       DEC(16,2);
define _credito_final      DEC(16,2);
define _monto_tran         dec(16,2); 
define _diferencia_saldo   dec(16,2);
define _suma_total         dec(16,2);
DEFINE _mes    		 SMALLINT;
DEFINE _ano    	     SMALLINT;
define _no_registro     char(10);
define _cod_auxiliar	char(5);
define _cantidad		smallint;

		
delete from rea_saldo
where periodo = a_periodo;

call sp_rea24bb(a_compania, a_sucursal,a_periodo, a_periodo) returning _error, _descripcion;

LET _ano = a_periodo[1,4];
LET _mes = a_periodo[6,7];

IF _mes = 01 THEN
   LET _mes = 12;
   LET _ano = _ano - 1;
ELSE
   LET _mes = _mes - 1;
END IF

LET _fecha = MDY(_mes, 1, _ano);
let _periodo = sp_sis39(_fecha);

call sp_rea24bb(a_compania, a_sucursal,_periodo,a_periodo) returning _error, _descripcion;

let _diferencia_saldo = 0.00;
let _saldo_ant = 0.00;

	  
let _credito_final = 0;
let _debito_final = 0;

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
  where r.no_registro = a.no_registro
    and a.periodo     = a_periodo
	and cuenta        = '2550101'
	and r.no_documento = '0103-00374-01'

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
     where no_documento = _doc_poliza
	   and cod_coasegur = _cod_coasegur
	   and periodo      = a_periodo;

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
			   set monto_tran   =  monto_tran + _monto_tran
			 where no_documento = _doc_poliza
			   and cod_coasegur = _cod_coasegur
			   and periodo      = a_periodo;							
		end if						
			
--	let _diferencia_saldo = _saldo_ant - _saldo_reaseg;
	--let _suma_total = _monto_tran - _diferencia_saldo;
		
end foreach

return 0, "Actualizacion Exitosa";

{
	return _cod_coasegur,                                    
	       _nombre_reas,                                                                             
		   _doc_poliza,                                       
		   _saldo_ant,	                                     
		   _saldo_reaseg,                                      
		   _diferencia_saldo,                               
		   _monto_tran,                                   
		   _periodo,
		   _cod_ramo,
		   _nombre WITH RESUME;                           
}

--DROP TABLE rea_saldo;
--DROP TABLE tmp_rea_saldo1;







return 0, "Actualizacion Exitosa";

end procedure