-- Reporte para las requisiciones de Reclamos de Auto por imprimir

-- Creado    : 12/07/2006 - Autor: Amado Perez

drop procedure sp_che224;
create procedure sp_che224()
 returning char(10) as requis,
		   char(10) as cod_cliente,
		   char(100) as a_nombre_de,
		   dec(16,2) as monto,
		   char(1)   as periodo_pago,
		   char(50)  as tipo_pago,
		   char(18)  as no_reclamo,
		   date      as fecha_captura,
		   integer   as dias_30,
		   integer   as dias_60,
		   integer   as dias_90,
		   integer   as mas_de_90,
		   date      as fecha_captura_mas_25;

define _no_requis		char(10);
define _cod_cliente		char(10);
define _nom_tipopago	char(50);
define _monto			dec(16,2);
define _cod_tipopago    char(3);
define _periodo_pago    smallint;
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _a_nombre_de		char(100);
define _firma1			char(8);
define _firma2			char(8);
define _numrecla        char(18);
define _user_added      char(8);
define _fecha_hoy       date;
define _fecha_captura   date;
define _dias		    integer;
define _dias30 			integer;
define _dias60 			integer;
define _dias90			integer;
define _diasmas90		integer;
define _per_pago_char   char(1);
define _fecha_mas_25    date;

SET ISOLATION TO DIRTY READ;

let _fecha_hoy = current;
let _dias      = 0;

foreach
select cod_banco,
       cod_chequera
  into _cod_banco,
	   _cod_chequera
  from chqbanch
 where cod_ramo in ('002', '020', '023')
 group by cod_banco, cod_chequera


	foreach
	 select	no_requis,
			cod_cliente,
			monto,
			a_nombre_de,
			periodo_pago,
			firma1,
			firma2,
			user_added,
			fecha_captura
	   into	_no_requis,
			_cod_cliente,
			_monto,
			_a_nombre_de,
			_periodo_pago,
			_firma1,
			_firma2,
			_user_added,
			_fecha_captura
	   from	chqchmae
	  where anulado       = 0
		and cod_banco     = _cod_banco
		and cod_chequera  = _cod_chequera
		and en_firma      = 2
		and origen_cheque <> "S"
--		and autorizado    = 1
		and pagado        = 0

	--	and cod_cliente   = "32659"

	 let _cod_tipopago = "";
	 let _numrecla     = "";
   --	 let _user_added   = "";

	 foreach
		select cod_tipopago, numrecla -- , user_added
		  into _cod_tipopago, _numrecla --, _user_added
		  from rectrmae
		 where no_requis   = _no_requis
		   and actualizado = 1
		exit foreach;
	 end foreach
	 
	 if _numrecla[1,2] not in ('02','20','23') then
		continue foreach;
	 end if
	   
	 select nombre
	   into _nom_tipopago
	   from rectipag
	  where cod_tipopago = _cod_tipopago;
	  
	  let _dias = _fecha_hoy - _fecha_captura;
	  let _dias30 = 0;
	  let _dias60 = 0;
	  let _dias90 = 0;
	  let _diasmas90 = 0;
	let _fecha_mas_25 = _fecha_captura + 25 units day;
	
	if _dias >= 0 And _dias <= 30 then
			let _dias30 = _dias;
	elif _dias >= 31 And _dias <= 60 then
			let _dias60 = _dias;
	elif _dias >= 61 And _dias <= 90 then
			let _dias90 = _dias;
	elif _dias >= 91 then
			let _diasmas90 = _dias;
	end if

		if _periodo_pago = 0 then
			let _per_pago_char = 'D';
		elif _periodo_pago = 1 then
			let _per_pago_char = 'S';
		else
			let _per_pago_char = 'M';
		end if
		
		return _no_requis,
			   _cod_cliente,
			   _a_nombre_de,
			   _monto,
			   _per_pago_char,
			   _nom_tipopago,
			   _numrecla, 
			   _fecha_captura,
			   _dias30,
			   _dias60,
			   _dias90,
			   _diasmas90,
			   _fecha_mas_25 with resume;

	end foreach
end foreach
end procedure
