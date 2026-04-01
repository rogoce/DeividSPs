-- Creacion de Remesa de Comision de Descontada cuando la poliza esta en Pago adelantado de comision y fue cancelada
-- Creado     : 11/10/2012 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_che169;
create procedure "informix".sp_che169(a_periodo char(7))
returning smallint,
          char(100);

define _descripcion			char(100);
define _error_desc			char(100);
define _null				char(1);
define _nom_cuenta			char(50);
define _recibi_de			char(50);
define _cuenta				char(25);													 
define _no_documento		char(20);
define _no_factura			char(10);
define _no_remesa			char(10);													 										 
define _no_poliza			char(10);
define _user				char(8);
define _periodo				char(7);
define _cod_auxiliar		char(5);
define _cod_agente			char(5);
define _cod_sucursal		char(3);
define _cod_compania		char(3);
define _caja_caja			char(3);
define _caja_comp			char(3);
define _cta_aux				char(1);
define _renglon				smallint;
define _cant				smallint;
define _error_isam			integer;
define _error				integer;
define _fecha				date;
define _monto_descontado	dec(16,2);
define _monto_bono		    dec(16,2);
define _monto_recibo		dec(16,2);
define _porc_bono           dec(16,2);


begin
 on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

set isolation to dirty read;

let _cod_compania		= '001';
let _cod_sucursal		= '001';
let _recibi_de			= 'Bono Vida Individual(Nuevas) '||a_periodo;
let _no_documento		= '';
let _cod_agente			= '';
let _fecha				= current;  --'30/09/2014'; --current;
let _renglon			= 0;
let	_monto_bono		    = 0.00;
let _null				= null;

--set debug file to "sp_cob169.trc";
--trace on;

 select count(*)	 
   into _cant
   from endedmae e, emipomae p, chqbono019 r
  where e.no_poliza = p.no_poliza
	and p.cod_ramo = '019'
	and e.cod_endomov = '002'
	and e.periodo = a_periodo
	and e.actualizado = 1
	and p.estatus_poliza = 2
	and e.no_poliza = r.no_poliza 
	and r.monto_bono > 0; 
	
if _cant = 0  or _cant = _null then
	return 0, 'No hay Recupero de Bono Vida Individual(Nuevas), Periodo: '||a_periodo;
end if		

let _no_remesa   = sp_sis13("001", 'COB', '02', 'par_no_remesa');
let _user = 'DEIVID';

select count(*)
  into _cant
  from cobremae
 where no_remesa = _no_remesa;

if _cant <> 0 then
	return 1, 'El numero de remesa generado ya existe, por favor actualize nuevamente. ';
end if	

call sp_cob224() returning _caja_caja, _caja_comp;

if month(_fecha) < 10 then
	let _periodo = year(_fecha) || '-0' || month(_fecha);
else
	let _periodo = year(_fecha) || '-' || month(_fecha);
end if

insert into cobremae(
no_remesa,   
cod_compania,   
cod_sucursal,   
cod_banco,   
cod_cobrador,   
recibi_de,   
tipo_remesa,   
fecha,   
comis_desc,   
contar_recibos,   
monto_chequeo,   
actualizado,   
periodo,   
user_added,   
date_added,   
user_posteo,   
date_posteo,
cod_chequera
)
values(
_no_remesa,			-- no_remesa,   
_cod_compania,		-- cod_compania,  
_cod_sucursal,		-- cod_sucursal,  
_caja_caja,			-- cod_banco,   
_null,				-- cod_cobrador,  
_recibi_de,			-- recibi_de,   
'C',				-- tipo_remesa,   
_fecha,				-- fecha,   
0,					-- comis_desc,   
2,					-- contar_recibos,
0,		            -- monto_chequeo, 
0,					-- actualizado,   
_periodo,			-- periodo,   
_user,				-- user_added,   
_fecha,				-- date_added,   
_user,				-- user_posteo,   
_fecha,				-- date_posteo,
_caja_comp			-- cod_chequera
);


foreach
	 select e.no_documento, e.user_added, e.no_factura,  r.cod_agente, r.monto_bono, r.no_poliza,r.porc_bono
	   into _no_documento, _user, _no_factura, _cod_agente, _monto_bono, _no_poliza, _porc_bono	
	   from endedmae e, emipomae p, chqbono019 r
	  where e.no_poliza = p.no_poliza
		and p.cod_ramo = '019'
		and e.cod_endomov = '002'
		and e.periodo = a_periodo
		and e.actualizado = 1
		and p.estatus_poliza = 2
		and e.no_poliza = r.no_poliza
		and r.monto_bono > 0;		
	
	let _renglon	= _renglon + 1;
	let _monto_bono	= _monto_bono * -1;
	let _descripcion	= 'Recupero de Bono Vida Individual(Nuevas) '||a_periodo;

	insert into cobredet(
		    no_remesa,
		    renglon,
		    cod_compania,
		    cod_sucursal,
		    no_recibo,
		    doc_remesa,
		    tipo_mov,
		    monto,
		    prima_neta,
		    impuesto,
		    monto_descontado,
		    comis_desc,
		    desc_remesa,
		    saldo,
		    periodo,
		    fecha,
		    actualizado,
			no_poliza,
			cod_agente
			)
	values	(
			_no_remesa,			-- _no_remesa,
			_renglon,			-- _renglon,
			_cod_compania,		-- _cod_compania,
			_cod_sucursal,		-- _cod_sucursal,
			_no_factura,		-- _no_recqibo_ancon,
			_no_documento,		-- _no_documento,
			'C',				-- _tipo_mov,
			_monto_bono,	    -- _monto,
			0,					-- _prima,
			0,					-- _impuesto,
			0,					-- _monto_descontado,
			0,					-- _comis_desc,
			_descripcion,		-- _descripcion,
			0,					-- _saldo,
			_periodo,			-- _periodo,
			_fecha,				-- _fecha,
			0,					-- 0,
			_no_poliza,		    -- _no_poliza
			_cod_agente
			);

	-- Afectacion de la catalago a la cuenta de adelanto de comision	
	let _cuenta			= sp_sis15('PGCOMCO', '01', _no_poliza);			
	let _renglon		= _renglon + 1;

	select cta_nombre,
		   cta_auxiliar	
	  into _nom_cuenta,
		   _cta_aux	
	  from cglcuentas
	 where cta_cuenta = _cuenta;										   

	let _cod_auxiliar = null;												 	   

	if _cta_aux = 'S' then											 	   
		let _cod_auxiliar = "A" || _cod_agente[2,5]; -- En SAC no alcanza para poner los 5 digitos
	end if

	let _descripcion	= 'AFECTACION DE CATALOGO:' || trim(_nom_cuenta);
	
	insert into cobredet(
			no_remesa,
			renglon,
			cod_compania,
			cod_sucursal,
			no_recibo,
			doc_remesa,
			tipo_mov,
			monto,
			prima_neta,
			impuesto,
			monto_descontado,
			comis_desc,
			desc_remesa,
			saldo,
			periodo,
			fecha,
			actualizado,
			no_poliza,
			cod_agente,
			cod_auxiliar)
	values	(_no_remesa,
			_renglon,
			_cod_compania,
			_cod_sucursal,
			_no_factura,
			_cuenta,
			'M',
			abs(_monto_bono),
			0,
			0,
			0,
			0,
			_descripcion,
			0,
			_periodo,
			_fecha,
			0,
			_no_poliza,
			_cod_agente,
			_cod_auxiliar);			
			
     update chqbono019
	    set recupero = 1, 
		    date_recupero = current
      where no_poliza = _no_poliza
	    and periodo = a_periodo;	    
		
     update chqbono019e
	    set bono_recupero = bono_recupero + _bono_queda, 
		    bono_queda = _bono_queda
		    ult_fecha_recupero = current
      where no_poliza = _no_poliza
	    and periodo = a_periodo;			
	
end foreach

select sum(monto)
  into _monto_recibo
  from cobredet
 where no_remesa = _no_remesa; 


{call sp_cob29(_no_remesa,_user) returning _error, _error_desc;

if _error <> 0 then
	return _error, _error_desc;
end if}

return 0,' Remesa de Recupero.'||_no_remesa;

end
end procedure