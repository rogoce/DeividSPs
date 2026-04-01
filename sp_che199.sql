------------------------------------------------
--   Detalle de Pre Autoriza ACH   Reclamos     --
--   Cliente Banisi --
---  Amado - 11/03/2022 --
------------------------------------------------
drop procedure sp_che199;
create procedure sp_che199(a_opc smallint, a_cod_banco char(3))
			
returning	char(10) as no_requis,
            char(25) as cuenta,
			char(10) as cod_cliente,
			char(5)  as cod_agente,
			char(3)  as cod_banco,
			char(3)  as cod_chequera,
			char(3)  as cod_compania,
			char(3)  as cod_sucursal,
			integer  as no_cheque,
			date     as fecha_impresion,
			date     as fecha_captura,
			smallint as autorizado,
			smallint as pagado,
			varchar(100) as a_nombre_de,
			smallint as cobrado,
			date as fecha_cobrado,
			smallint as anulado,
			date as fecha_anulado,
			char(8) as anulado_por,
			dec(16,2) as monto,
			char(7) as periodo,
			char(8) as user_added,
			char(8) as autorizado_por,
			char(1) as origen_cheque,
			char(2)  as cod_ruta,
			date as fecha,
			integer as dias,
			smallint as prioridad,
			char(8) as user_pre_aut,
			datetime year to fraction(5) as date_pre_aut;
																																												  
begin

define _no_requis 		char(10);   
define _cuenta          char(25);
define _cod_cliente     char(10);
define _cod_agente      char(5);
define _cod_banco       char(3);
define _cod_chequera    char(3);  
define _cod_compania    char(3);   
define _cod_sucursal    char(3);   
define _no_cheque       integer;
define _fecha_impresion date;   
define _fecha_captura 	date;   
define _autorizado 		smallint;   
define _pagado          smallint;
define _a_nombre_de		varchar(100);
define _cobrado         smallint;  
define _fecha_cobrado   date;   
define _anulado         smallint;   
define _fecha_anulado   date;   
define _anulado_por     char(8);   
define _monto 			dec(16,2);   
define _periodo         char(7);   
define _user_added      char(8);   
define _autorizado_por  char(8);   
define _origen_cheque   char(1);   
define _incidente       integer;
define _aut_workflow    smallint;
define _firma1          char(20);
define _firma2          char(20);
define _cod_ruta        char(2);
define _en_firma        smallint;

define _cod_ramo 		char(3);
define _cant   			smallint;
define _cantt			smallint;	 
define _cant_chqchrec   smallint;
define _numrecla        char(20);
define _transaccion     char(10);
define _prioridad 		smallint;  
define _prioridad_tmp 	smallint;  
define _cant_agt        smallint;
define _no_documento    char(20);
define _no_poliza       char(10);
define _perd_total      smallint;
define _agente          varchar(50);
define _cod_grupo       char(5);
define _cod_tipopago    char(3);
define _tipo_pago       varchar(50);
define _perdida         varchar(15);
define _saldo           dec(16,2);
define _dias            integer;
define _date_doc_comp   date;
define _cod_asignacion  char(10);
define _fecha_scan      date;
define _fecha_cont      date;
define _cod_contratante char(10);
define _contratante     varchar(100);
define _cod_area        smallint;
define _nota_excepcion  varchar(255);
define _cod_entrada     char(10);
define _no_reclamo      char(10);
define _dias_compara    smallint;
define _dias_compara_tmp smallint;
define _no_tranrec      char(10);
define _dia_taller      smallint;
define _dia_asegurado   smallint;
define _cant_ajust      smallint;
define _cant_serv       smallint;
define _fecha_factura   date;
define _fecha_capt_ori  date;
define _user_pre_aut    char(8);
define _date_pre_aut    datetime year to fraction(5);  
define _user_excepcion  char(8);
define _date_excepcion  datetime year to fraction(5);
define _deducible       smallint;
define _sum_deducible   dec(16,2);
define _cod_chequera_p  char(3);
define _finiquito_firmado smallint;

	--set debug file to "sp_che149.trc";
	--trace on;

set isolation to dirty read;	   

let _prioridad = 0;

if a_cod_banco = '001' then
	if a_opc = 2 then
		let _cod_chequera_p = '006';
	else
		let _cod_chequera_p = '001';
	end if
elif a_cod_banco = '295' then
	let _cod_chequera_p = '045';
end if
	   
foreach
  SELECT no_requis,   
         cuenta,   
         cod_cliente,   
         cod_agente,   
         cod_banco,   
         cod_chequera,   
         cod_compania,   
         cod_sucursal,   
         no_cheque,   
         fecha_impresion,   
         fecha_captura,   
         autorizado,   
         pagado,   
         a_nombre_de,   
         cobrado,   
         fecha_cobrado,   
         anulado,   
         fecha_anulado,   
         anulado_por,   
         monto,   
         periodo,   
         user_added,   
         autorizado_por,   
         origen_cheque,   
         incidente,   
         aut_workflow,   
         firma1,   
         firma2,   
         cod_ruta,   
         en_firma,
         nota_excepcion,
         user_excepcion,
         date_excepcion,
         user_pre_aut,
         date_pre_aut,
         finiquito_firmado		 
	INTO _no_requis,   
         _cuenta,   
         _cod_cliente,   
         _cod_agente,   
         _cod_banco,   
         _cod_chequera,   
         _cod_compania,   
         _cod_sucursal,   
         _no_cheque,   
         _fecha_impresion,   
         _fecha_captura,   
         _autorizado,   
         _pagado,   
         _a_nombre_de,   
         _cobrado,   
         _fecha_cobrado,   
         _anulado,   
         _fecha_anulado,   
         _anulado_por,   
         _monto,   
         _periodo,   
         _user_added,   
         _autorizado_por,   
         _origen_cheque,   
         _incidente,   
         _aut_workflow,   
         _firma1,   
         _firma2,   
         _cod_ruta,   
         _en_firma,
         _nota_excepcion,		 
         _user_excepcion,
         _date_excepcion,
         _user_pre_aut,
         _date_pre_aut,
         _finiquito_firmado		 
    FROM chqchmae  
   WHERE ( origen_cheque = "1" ) AND  
         ( cod_chequera = _cod_chequera_p) AND 
         ( pagado = 0 ) AND  
         ( tipo_requis = 'A' ) AND  
--         ( en_firma = 2 ) AND
		 ( aut_imp_tec = 0) AND
		 ( cod_banco = a_cod_banco) 
ORDER BY a_nombre_de
   
    let _fecha_capt_ori = _fecha_captura;
    let _fecha_cont = _fecha_captura;  
	let _prioridad = 0;
	let _dias = today - _fecha_cont;    
	let _prioridad = 0;
    let _contratante = null; 	
	let _dia_asegurado = 25;
	let _dia_taller = 30;
 	let _deducible = 0;
	let _cant_chqchrec = 0;
	let _cant = 0;
			
	 	
	return   _no_requis,   
			 _cuenta,   
			 _cod_cliente,   
			 _cod_agente,   
			 _cod_banco,   
			 _cod_chequera,   
			 _cod_compania,   
			 _cod_sucursal,   
			 _no_cheque,   
			 _fecha_impresion,   
			 _fecha_captura,   
			 _autorizado,   
			 _pagado,   
			 _a_nombre_de,   
			 _cobrado,   
			 _fecha_cobrado,   
			 _anulado,   
			 _fecha_anulado,   
			 _anulado_por,   
			 _monto,   
			 _periodo,   
			 _user_added,   
			 _autorizado_por,   
			 _origen_cheque,   
			 _cod_ruta,   
             _fecha_cont,
			 _dias,
             _prioridad,
			 _user_pre_aut,
			 _date_pre_aut with resume;  	

		
		
end foreach	


end

end procedure  

 
		