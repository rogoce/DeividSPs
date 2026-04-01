-- Hoja de Auditoria para Reclamos de Salud

-- Creado    : 20/09/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 20/09/2001 - Autor: Demetrio Hurtado Almanza
-- Modificado: 27/02/2002 - Autor: Amado Perez - cambio fecha_gasto por fecha_siniestro
--                                 por orden de Rosa Elena
--
-- SIS v.2.0 - d_recl_sp_rec55_dw1 - DEIVID, S.A.
drop procedure sp2_rec55c;
create procedure sp2_rec55c(
a_compania			char(3), 
a_no_documento		char(20),
a_ano				char(4)	 default "*",
a_cod_asegurado		char(10) default "*",
a_cod_reclamante	char(10) default "*",
a_no_reclamo		char(20) default "*",
a_ano_poliza        smallint default 0
)
returning char(20),				 
          date,					
		  char(10),				
		  char(10),				
		  dec(16,2),			
		  dec(16,2),			
		  dec(16,2),			
		  dec(16,2),			
		  dec(16,2),			
		  dec(16,2),			
		  char(100),			
		  dec(16,2),			
		  char(100),			
		  char(100),			
		  char(10),				
		  char(10),				
		  char(50),				
		  char(10),				
		  char(100),			
		  date,					
		  date,					
		  char(50),				
		  char(100),			
		  char(100),			
		  char(7),				
		  char(50),
		  char(50),
		  dec(16,2),
		  date,
		  date,
		  smallint,	
		  char(10),
		  char(7),
		  date,
		  integer,
		  integer,
		  char(10),
		  char(5),
		  char(50),
		  char(50);

define _numrecla		char(20);
define _fecha_siniestro	date;
define _cod_icd			char(10);
define _cod_cpt			char(10);
define _no_reclamo		char(10);
define _cod_reclamante	char(10);
define _cod_asegurado	char(10);
define _nombre_recla	char(100);
define _nombre_aseg		char(100);

define _gasto_fact		dec(16,2);
define _gasto_eleg		dec(16,2);
define _a_deducible		dec(16,2);
define _co_pago			dec(16,2);
define _coaseguro		dec(16,2);
define _pago_prov		dec(16,2);
define _nombre_prov		char(100);
define _gastos_no_cub	dec(16,2);

define _cod_proveedor	char(10);
define _nombre_cia 		char(50);
define _no_unidad		char(10);
define _cod_contratante	char(10);
define _nombre_cont		char(100);
define _no_poliza		char(10);
define _no_endoso		char(5);
define _vigencia_inic	date;
define _vigencia_final	date;
define _filtro_ano		char(100);
define _filtro_aseg		char(100);
define _filtro_recla	char(100);
define _cod_tipotran    char(3);
define _fecha_gasto		date;
define _periodo			char(7);
define _dependencia		char(50);
define _cod_parentesco  char(3);
define _no_tranrec		char(10);
define _cod_tipotran2   char(3);
define _cod_tipotran_rec   char(3);
define _ahorro          dec(16,2);
define _ano             integer;
define _vig_fin_i       date;
define _vig_ini_i       date;

define _nombre_icd		char(100);
define _anular_nt       char(10);
define _fecha_factura	date;
define _cod_tipo        char(3);
define _exterior        smallint;

define _transaccion 	char(10);
define _periodo_tran	char(7);
define _fecha_tran      date;
define _anio_factura    integer;
define _mes_factura     integer;
define _cod_tipopago3   char(3);
define _cod_tipotran3   char(3);
define _desc_tipotran3	char(50);
define _desc_tipopago3	char(50);

set isolation to dirty read;

select cod_tipotran
  into _cod_tipotran
  from rectitra
 where tipo_transaccion = 4;

select cod_tipotran
  into _cod_tipotran2
  from rectitra
 where tipo_transaccion = 13;

select cod_tipotran
  into _cod_tipotran_rec
  from rectitra
 where tipo_transaccion = 6;


let _nombre_cia  = sp_sis01(a_compania); 
let a_no_reclamo = trim(a_no_reclamo);
let _vig_ini_i = '01/01/1900';
let _vig_fin_i = '01/01/1900';
let _cod_tipotran3 = '';
let _cod_tipopago3 = '';		
let _desc_tipotran3 = '';
let _desc_tipopago3 = '';
foreach
 select	numrecla,
		cod_icd,
        fecha_siniestro,
		cod_reclamante,
		cod_asegurado,
		no_reclamo,
		no_unidad,
		no_poliza,
		periodo
   into	_numrecla,
		_cod_icd,
        _fecha_siniestro,
		_cod_reclamante,
		_cod_contratante,
		_no_reclamo,
		_no_unidad,
		_no_poliza,
		_periodo
   from recrcmae
  where	no_documento   = a_no_documento
    and actualizado    = 1
	and cod_reclamante matches a_cod_reclamante
	and numrecla       matches a_no_reclamo

	select vigencia_inic,
	       vigencia_final,
		   cod_contratante
	  into _vigencia_inic,
	       _vigencia_final,
		   _cod_contratante
	  from emipomae
	 where no_poliza = _no_poliza;
	 
    if a_ano_poliza = 1 then
	    let _ano = a_ano;
		call sp_sis21d(_vigencia_inic,_ano) returning _vig_ini_i, _vig_fin_i;
	end if
	select nombre
	  into _nombre_icd
	  from recicd
	 where cod_icd = _cod_icd;

	if _cod_icd is null then
		let _cod_icd    = "";
		let _nombre_icd = "";
	end if

	select nombre
	  into _nombre_cont
	  from cliclien
	 where cod_cliente = _cod_contratante;

	select nombre
	  into _nombre_recla
	  from cliclien
	 where cod_cliente = _cod_reclamante;

	let _cod_asegurado = null;
		
	foreach
	 select cod_asegurado
	   into _cod_asegurado
	   from emipouni
	  where no_poliza = _no_poliza
	    and no_unidad = _no_unidad
	    	exit foreach;
	end foreach  

	if _cod_asegurado is null then
		let _cod_asegurado = _cod_reclamante;
	end if

	if a_cod_asegurado <> "*" then 
		if a_cod_asegurado <> _cod_asegurado then
			continue foreach;
		end if
	end if		   	 

	select nombre
	  into _nombre_aseg
	  from cliclien
	 where cod_cliente = _cod_asegurado;

	-- Descripcion de Filtros

	if a_ano = "*" then
		let _filtro_ano = "Todos los Años";
	else
		let _filtro_ano = a_ano;
	end if
	
	if a_cod_asegurado = "*" then
		let _filtro_aseg = "Todos los Asegurados";
	else
		let _filtro_aseg = _nombre_aseg;
	end if

	if a_cod_reclamante = "*" then
		let _filtro_recla = "Todos los Reclamantes";
	else
		let _filtro_aseg  = _nombre_aseg;
		let _filtro_recla = _nombre_recla;
	end if

	-- Descripcion de las Dependencias

	if _cod_asegurado = _cod_reclamante then
	
		let _dependencia = "ASEGURADO PRINCIPAL";
	
	else

		let _dependencia = null;

		select cod_parentesco
		  into _cod_parentesco
		  from emidepen
		 where no_poliza   = _no_poliza
		   and no_unidad   = _no_unidad
		   and cod_cliente = _cod_reclamante;

		select nombre
		  into _dependencia
		  from emiparen
		 where cod_parentesco = _cod_parentesco;

		if _dependencia is null then
			let _dependencia = "";
		end if

			
	end if		

	-- Transacciones de Reclamos
    let _anular_nt = null; --Se excluyen las N/T anuladas por instr. Dra. Cesar correo 01/02/2018
	let _cod_tipotran3 = '';
	let _cod_tipopago3 = '';
	foreach
	 select cod_cliente,
			fecha,
			cod_cpt,
			no_tranrec,
			fecha_factura,
			anular_nt,
			transaccion,
			periodo,
            cod_tipopago,
            cod_tipotran			
	   into	_cod_proveedor,
			_fecha_gasto,
			_cod_cpt,
			_no_tranrec,
			_fecha_factura,
			_anular_nt,
			_transaccion,
            _periodo_tran,
			_cod_tipopago3,
			_cod_tipotran3
	   from rectrmae
	  where no_reclamo   = _no_reclamo
	    and actualizado  = 1
		and (cod_tipotran = _cod_tipotran
		 or cod_tipotran  = _cod_tipotran2
		 or cod_tipotran  = _cod_tipotran_rec
		 )

		if _fecha_factura is null then
			let _fecha_factura = _fecha_gasto;
		end if
		if _anular_nt is not null then
			continue foreach;
		end if
		
		let _fecha_tran = _fecha_gasto;
		let _anio_factura = year(_fecha_factura);
		let _mes_factura = month(_fecha_factura);		

		if a_ano <> "*" then
		    if a_ano_poliza = 0 then
				if year(_fecha_factura) <> a_ano then
					continue foreach;
				end if
			else
				if (_fecha_factura >= _vig_ini_i) and (_fecha_factura <= _vig_fin_i) then
				else
					continue foreach;
				end if
			end if
		end if		   	 
		
		if _cod_cpt is null then
			let _cod_cpt = "";
		end if

		select nombre
		  into _nombre_prov
		  from cliclien
		 where cod_cliente = _cod_proveedor;
		 
		let _desc_tipotran3 = '';
		select trim(cod_tipotran)||' - '||trim(nombre)
		  into _desc_tipotran3
		  from rectitra
		 where cod_tipotran = _cod_tipotran3;		
	 
		let _desc_tipopago3 = '';		 
		select trim(cod_tipopago)||' - '||trim(nombre)
		  into _desc_tipopago3
		  from rectipag
		 where cod_tipopago = _cod_tipopago3;		

		foreach
			select facturado,
				   elegible,
				   a_deducible,
				   co_pago,
				   coaseguro,
				   monto,
				   monto_no_cubierto,
				   ahorro,
				   cod_tipo
			  into _gasto_fact,
				   _gasto_eleg,
				   _a_deducible,
				   _co_pago,
				   _coaseguro,
				   _pago_prov,
				   _gastos_no_cub,
				   _ahorro,
				   _cod_tipo
			  from rectrcob
			 where no_tranrec = _no_tranrec
			 
			select exterior
			  into _exterior
			  from prdticob
			 where cod_tipo = _cod_tipo;

			return _numrecla,		   -- 1
			       _fecha_factura,     -- 2
				   _cod_icd,		   -- 3
				   _cod_cpt,		   -- 4
				   _gasto_fact,		   -- 5		
				   _gasto_eleg,		   -- 6
				   _a_deducible,	   -- 7
				   _co_pago,		   -- 8	
				   _coaseguro,		   -- 9
				   _pago_prov,		   -- 10
				   _nombre_prov,	   -- 11	
				   _gastos_no_cub,	   -- 12
				   _nombre_cont,	   -- 13
				   _nombre_recla,	   -- 14
				   _cod_contratante,   -- 15
				   _cod_reclamante,	   -- 16
				   _nombre_cia,		   -- 17
				   _cod_asegurado,	   -- 18
				   _nombre_aseg,	   -- 19
				   _vigencia_inic,	   -- 20
				   _vigencia_final,	   -- 21
				   _filtro_ano,		   -- 22
				   _filtro_aseg,	   -- 23
				   _filtro_recla,	   -- 24
				   _periodo,		   -- 25
				   _dependencia,	   -- 26
				   _nombre_icd,		   -- 27	
				   _ahorro,
				   _vig_ini_i,
				   _vig_fin_i,
				   _exterior,
				   _transaccion,
				   _periodo_tran,
				   _fecha_tran,
				   _anio_factura,
				   _mes_factura,
				   _no_tranrec,
				   _no_unidad,
				   _desc_tipotran3,
				   _desc_tipopago3
				   with resume;

		end foreach
		let _cod_tipotran3 = '';
		let _cod_tipopago3 = '';		
		let _desc_tipotran3 = '';
		let _desc_tipopago3 = '';
	end foreach
end foreach
end procedure;
