-- Procedimiento que Genera la Remesa de Aplicacion de transacciones de reclamos de coaseguro
-- 
-- Creado    : 18/11/2009 - Autor: Demetrio Hurtado Almanza
-- modificado: 18/11/2009 - Autor: Demetrio Hurtado Almanza
-- 
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob220;

create procedure "informix".sp_cob220(a_periodo char(7))
returning integer,
		  char(50);

define _descripcion   	char(100);
define _estoy           char(50);
define _no_documento 	char(18); 
define _cod_cliente   	char(10);
define a_no_remesa 		char(10);
define _no_reclamo		char(10);
define _no_poliza    	char(10); 
define _no_tranrec		char(10);
define a_no_recibo      char(10);
define _periodo			char(7);
define _cod_auxiliar	char(5);
define _ano_char		char(4);
define _par_ase_lider	char(3);
define _cod_tipoprod	char(3);
define _cod_compania	char(3);
define _cod_coasegur	char(3);
define _cod_sucursal	char(3);
define _tipo_remesa     char(1);
define _tipo_mov        char(1);
define _null			char(1);
define _saldo        	dec(16,2);
define _cantidad		smallint;
define _error_code      integer;
define _renglon      	integer;
define _fecha			date;

--set debug file to "sp_cob125.trc";
--trace on;

begin work;

begin

on exception set _error_code 
	rollback work;
 	return _error_code, _estoy;         
end exception           

set isolation to dirty read;

let a_no_remesa   = sp_sis13("001", 'COB', '02', 'par_no_remesa');
let _null         = null;
let _cod_compania = "001";
let _cod_sucursal = "001";

select fecha
  into _fecha
  from cobremae
 where no_remesa = a_no_remesa;

if _fecha is not null then
	rollback work;
	return 1, 'El Numero de Remesa Generado Ya Existe, Por Favor Actualize Nuevamente ...';
end if

select par_ase_lider
  into _par_ase_lider
  from parparam 
 where cod_compania = _cod_compania;

let _fecha = today;

if month(_fecha) < 10 then
	let _periodo = year(_fecha) || '-0' || month(_fecha);
else
	let _periodo = year(_fecha) || '-' || month(_fecha);
end if

-- Numero de Comprobante
let a_no_recibo = 'CD';	-- Comprobantes

if day(_fecha) < 10 then
	let a_no_recibo = trim(a_no_recibo) || '0' || day(_fecha);
else
	let a_no_recibo = trim(a_no_recibo) || day(_fecha);
end if

if month(_fecha) < 10 then
	let a_no_recibo = trim(a_no_recibo) || '0' || month(_fecha);
else
	let a_no_recibo = trim(a_no_recibo) || month(_fecha);
end if

let _ano_char   = year(_fecha);
let a_no_recibo = trim(a_no_recibo) || _ano_char[3,4];

-- Insertar el Maestro de Remesas

let _estoy = "COBREMAE";

insert into cobremae
values(	a_no_remesa,
		"001",
		"001",
		'001',
		_null,
		"ACTUALIZACION RECLAMOS DE COASEGURO",
		'C',
		_fecha,
		1,
		3,
		0.00,
		0,
		_periodo,
		"informix",
		_fecha,
		"informix",
		_fecha,
		1);

-- Inicializar Tablas

delete from cobreagt
 where no_remesa = a_no_remesa;

delete from cobredet
 where no_remesa = a_no_remesa;

let _renglon = 0;

foreach
	select cod_cliente,
		   numrecla,
		   monto,
		   no_reclamo,
		   no_tranrec
	  into _cod_cliente,
		   _no_documento,
		   _saldo,
		   _no_reclamo,
		   _no_tranrec
	  from rectrmae
	 where periodo      = a_periodo
	   and pagado       = 0
	   and actualizado  = 1
	   and monto        <> 0.00
	   and cod_tipotran = "004"	

	select no_poliza
	  into _no_poliza	
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod <> "002" then
		continue foreach;
	end if	 

	select count(*)
	  into _cantidad
	  from emicoami
	 where no_poliza    = _no_poliza
	   and cod_coasegur <> _par_ase_lider;

	if _cantidad <> 1 then
		return 1, "No Hay Compania Coaseguro Minoritario, Poliza: " || _no_poliza;
	end if

	select cod_coasegur
	  into _cod_coasegur
	  from emicoami
	 where no_poliza    = _no_poliza
	   and cod_coasegur <> _par_ase_lider;

	 select cod_auxiliar
	   into _cod_auxiliar
	   from emicoase
	  where cod_coasegur = _cod_coasegur;

	-- Descripcion de la Remesa
	
	select nombre
	  into _descripcion
	  from cliclien
	 where cod_cliente = _cod_cliente;

	let _renglon  = _renglon + 1;
	let _tipo_mov = 'T';

	-- Detalle de la Remesa
    LET _estoy = "COBREDET " || _no_tranrec || " " || _no_documento;

	INSERT INTO cobredet(
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
	no_reclamo,
	no_tranrec,
	cod_auxiliar
	)
	VALUES(
    a_no_remesa,
    _renglon,
    _cod_compania,
    _cod_sucursal,
    a_no_recibo,
    _no_documento,
    _tipo_mov,
    _saldo,
    0,
    0,
    _saldo,
    0,
    _descripcion,
    0.00,
    _periodo,
    _fecha,
    0,
	null,
	_no_reclamo,
	_no_tranrec,
	_cod_auxiliar
	);

{	
	let _renglon      = _renglon  + 1;
	let _tipo_mov     = "M";
	let _no_documento = sp_sis15('RPRCXA');  

	select cta_nombre
	  into _descripcion
	  from cglcuentas
	 where cta_cuenta = _no_documento;

	INSERT INTO cobredet(
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
	cod_auxiliar

	)
	VALUES(
	a_no_remesa,
	_renglon,
	_cod_compania,
	_cod_sucursal,
	a_no_recibo,
	_no_documento,
	_tipo_mov,
	_saldo * -1,
	0.00,
	0.00,
	0,
	0,
	_descripcion,
	0.00,
	_periodo,
	_fecha,
	0,
	null,
	_cod_auxiliar
	);
}

end foreach

--rollback work;
commit work;

RETURN 0, "Actualizacion Exitosa, Remesa # " || a_no_remesa;

END

END PROCEDURE;
