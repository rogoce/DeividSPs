-- Reporte de analisis de cobredet con documento en suspenso
-- Creado    : 03/01/2020 - Autor: Henry Girón
-- SIS v.2.0 - d_cobr_sp_cob780_dw1 - DEIVID, S.A.
-- execute procedure sp_cob780_a('001')

drop procedure sp_cob780_a;
create procedure "informix".sp_cob780_a(
a_compania char(3)
) returning CHAR(10)  as no_remesa, 
			integer as renglon,
			date  as fecha, 
			dec(16,2) as monto_remesa,			
			varchar(30) as recibi_de,
			date as susp_fecha_doc,		
			char(30) as susp_documento,	
			dec(16,2)	as susp_monto,
			char(50)	as susp_poliza,
			char(50)	as susp_asegurado,
			char(50)	as susp_coaseguro,
			char(50)	as susp_ramo,
			char(50)	as susp_compania,
			char(10)    as susp_no_recibo,
			char(8)     as susp_user_added,
			char(50)    as susp_corredor,
			char(30)    as susp_cedula,
			varchar(100) as susp_observacion,
			varchar(30) as susp_poliza_coaseg,
			integer as actualizado,
			char(2) as tiene,
			integer as cantidad;			

define v_compania_nombre	char(50);
define v_asegurado			char(50); 
define v_coaseguro			char(50);
define _corredor			char(50);
define v_poliza				char(50); 
define v_ramo				char(50);
define v_doc_suspenso		char(30); 
define _cedula				char(30);
define _no_recibo_otro		char(10);
define _user_added			char(8);
define v_monto				dec(16,2);
define v_fecha				date;
define _poliza_coaseg       varchar(30);
define _observacion         varchar(100);
define _fecha               date;
define _monto               dec(16,2);
define v_actualizado        integer;
define _cantidad            integer;
define _renglon             integer;
define _no_remesa           CHAR(10);    
define _recibi_de           varchar(30);
define _tiene               char(2);



-- Nombre de la Compania

let  v_compania_nombre = sp_sis01(a_compania); 

-- Seleccion de las Primas en Suspenso
let _corredor   = "";
let _user_added	= "";
let _cedula		= "";
let _renglon = 0;

let  v_fecha = null;
let v_actualizado = null;
let v_monto = null;
let v_poliza = null;
let v_asegurado = null;
let v_coaseguro = null;
let v_ramo = null;
let _corredor = null;
let _user_added = null;
let _cedula = null;
let _observacion = null;
let _poliza_coaseg = null;
let v_actualizado = 0;
let _cantidad = 0;
	
	
select * 
  from cobsuspe
  into temp tmp_cobsuspe;

foreach 	
	select doc_suspenso,
		   fecha,
		   actualizado,
		   monto,
		   poliza,
		   asegurado,
		   coaseguro,
		   ramo,
		   corredor,
		   user_added,
		   cedula,
		   observacion,
		   poliza_coaseg
	  into v_doc_suspenso,
		   v_fecha,			       
		   v_actualizado,
		   v_monto,
		   v_poliza,
		   v_asegurado,
		   v_coaseguro,
		   v_ramo,
		   _corredor,
		   _user_added,
		   _cedula,
		   _observacion,
		   _poliza_coaseg
	  from tmp_cobsuspe			 		  
	 order by fecha 
	
	let _fecha = null;
	let _monto = null;
	let _no_remesa = null; 
	let _renglon = null;
	let _recibi_de = null;	
	let _no_recibo_otro = null;
	let _tiene = 'NO';			   
	let _cantidad = 0;
			   
	 select COUNT(*) 
	   into _cantidad
	  from cobredet 
	 where doc_remesa = v_doc_suspenso
	   and tipo_mov   = 'E';
	 
	 if _cantidad > 0 then
			let _tiene = 'SI';
			
			foreach	
			select b.no_recibo, b.doc_remesa, b.fecha, b.monto, a.no_remesa,b.renglon,a.recibi_de
			  into _no_recibo_otro, v_doc_suspenso, _fecha, _monto, _no_remesa, _renglon,_recibi_de
			  from cobremae a,cobredet b
			 where a.no_remesa = b.no_remesa
			   and b.actualizado  = 1		   
			   and b.doc_remesa = v_doc_suspenso
	           and b.tipo_mov   = 'E'	  							 
			 

			return	_no_remesa, 
					_renglon,
					_fecha, 
					_monto,						
					_recibi_de,
					v_fecha,			
					v_doc_suspenso,	
					v_monto,			
					v_poliza,		
					v_asegurado, 	
					v_coaseguro, 	
					v_ramo,
					v_compania_nombre,
					_no_recibo_otro,
					_user_added,
					_corredor,
					_cedula,
					_observacion,
					_poliza_coaseg,
					v_actualizado,
					_tiene,
					_cantidad
					with resume;	 		


			end foreach
			
	else
			return	_no_remesa, 
					_renglon,
					_fecha, 
					_monto,						
					_recibi_de,
					v_fecha,			
					v_doc_suspenso,	
					v_monto,			
					v_poliza,		
					v_asegurado, 	
					v_coaseguro, 	
					v_ramo,
					v_compania_nombre,
					_no_recibo_otro,
					_user_added,
					_corredor,
					_cedula,
					_observacion,
					_poliza_coaseg,
					v_actualizado,						
					_tiene,
					_cantidad
					with resume;	
					
	end if


end foreach
	

	

end procedure;

