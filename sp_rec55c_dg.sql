-- Hoja de Auditoria para Reclamos de Salud

-- Creado    : 20/09/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 20/09/2001 - Autor: Demetrio Hurtado Almanza
-- Modificado: 27/02/2002 - Autor: Amado Perez - cambio fecha_gasto por fecha_siniestro
--                                 por orden de Rosa Elena
-- Se solicita adicionar en el excel los Campos:transaccion,periodo_tran,fecha_tran,año_factura,mes_factura,no_tranrec  RGORDON: 27/04/2022 HGIRON
-- SIS v.2.0 - d_recl_sp_rec55_dw1 - DEIVID, S.A.
drop procedure sp_rec55c;
create procedure sp_rec55c(
a_compania			char(3), 
a_no_documento		char(20),
a_ano				char(4)	 default "*",
a_cod_asegurado		char(10) default "*",
a_cod_reclamante	char(10) default "*",
a_no_reclamo		char(20) default "*",
a_ano_poliza        smallint default 0
)
returning   char(20)  as  reclamo,
			date  as  Fecha_atencion,
			char(50)  as  icd9,
			char(10)  as  concepto,
			dec(16,2)  as  facturado,
			dec(16,2)  as  No_cubierto,
			dec(16,2)  as  elegible,
			dec(16,2)  as  A_deducible,
			dec(16,2)  as  ahorro,
			dec(16,2)  as  copago,
			dec(16,2)  as  coaseguro,
			dec(16,2)  as  pagado,
			char(100)  as  A_favor_de,
			varchar(100) as cobertura,
			varchar(100) as tipo,			
			char(50)  as  dependencia,
			date  as  Fecha_de_nac,
			char(100)  as  Nombre_contratante,
			char(100)  as  Nombre_reclamante,
			char(10)  as  Cod_contratante,
			char(10)  as  Cod_reclamante,
			char(50)  as  compania,
			char(10)  as  Cod_asegurado,
			char(100)  as  Nombre_asegurado,
			date  as  Vigencia_inic,
			date  as  Vigencia_final,
			char(50)  as  Filtro_ano,
			char(100)  as  Filtro_aseg,
			char(100)  as  Filtro_recla,
			char(7)  as  periodo,
			char(10)  as  Cod_icd,
			date  as  vig_ini_ap,
			date  as  vig_fin_ap,
			smallint  as  Exterior,
			varchar(50) as producto,
			char(10) as transaccion,
			char(7) as periodo_transaccion,	
			date as fecha_transaccion,     
			integer as anio_factura,    
			integer as mes_factura,
			char(10) as no_tranrec,
            varchar(50) as n_tipo_pago,
			char(5) as no_unidad;

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
define _ahorro          dec(16,2);
define _ano             integer;
define _vig_fin_i       date;
define _vig_ini_i       date;

define _nombre_icd		char(100);
define _anular_nt       char(10);
define _fecha_factura	date;
define _cod_tipo        char(3);
define _exterior        smallint;
define _fecha_nac       date;

define _cod_cobertura    char(5);
define _n_cobertura      char(50);
define _n_tipo           char(50);

define _cobertura_rec   varchar(100);
define _tipo_rec        varchar(100);
define _n_prod		    varchar(50);

define _transaccion 	char(10);
define _periodo_tran	char(7);
define _fecha_tran      date;
define _anio_factura    integer;
define _mes_factura     integer;

define _cod_tipopago    char(3);
define _n_tipo_pago     varchar(50);

set isolation to dirty read;

select cod_tipotran
  into _cod_tipotran
  from rectitra
 where tipo_transaccion = 4;

select cod_tipotran
  into _cod_tipotran2
  from rectitra
 where tipo_transaccion = 13;

let _n_prod = "";
let _nombre_cia  = sp_sis01(a_compania); 
let a_no_reclamo = trim(a_no_reclamo);
let _vig_ini_i = '01/01/1900';
let _vig_fin_i = '01/01/1900';
let _fecha_nac = null;

let _cobertura_rec = '';
let _tipo_rec = '';
		
foreach
	select numrecla,
		   cod_icd,
		   fecha_siniestro,
		   cod_reclamante,
		   cod_asegurado,
		   no_reclamo,
		   no_unidad,
		   no_poliza,
		   periodo
	  into _numrecla,
		   _cod_icd,
		   _fecha_siniestro,
		   _cod_reclamante,
		   _cod_contratante,
		   _no_reclamo,
		   _no_unidad,
		   _no_poliza,
		   _periodo
	  from recrcmae
	 where no_documento  = a_no_documento
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
	foreach
		select cod_cliente,
			   fecha,
			   cod_cpt,
			   no_tranrec,
			   fecha_factura,
			   anular_nt,
			   transaccion,
			   periodo,
               cod_tipopago			   
		  into _cod_proveedor,
			   _fecha_gasto,
			   _cod_cpt,
			   _no_tranrec,
			   _fecha_factura,
			   _anular_nt,
			   _transaccion,
               _periodo_tran,
               _cod_tipopago				   
		  from rectrmae
		 where no_reclamo   = _no_reclamo
		   and actualizado  = 1
		   and (cod_tipotran = _cod_tipotran
		    or cod_tipotran  = _cod_tipotran2)

		if _fecha_factura is null then
			let _fecha_factura = _fecha_gasto;
		end if
		if _anular_nt is not null then
			continue foreach;
		end if
		
		let _fecha_tran = _fecha_gasto;
		let _anio_factura = year(_fecha_factura);
		let _mes_factura = month(_fecha_factura);
		
		if _cod_tipotran = '004' and ( _cod_tipopago = '001' or _cod_tipopago = '003' ) then 		
		
			   select upper(nvl(trim(nombre),''))
				 into _n_tipo_pago
				 from rectipag
				where cod_tipopago = _cod_tipopago;			  	
		else 
		   let _n_tipo_pago = '';
		end if

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

		select nombre --,fecha_aniversario
		  into _nombre_prov --,_fecha_nac
		  from cliclien
		 where cod_cliente = _cod_proveedor;
		 
		select fecha_aniversario
		  into _fecha_nac
		  from cliclien
		 where cod_cliente = _cod_reclamante;
		 
		let _n_prod = "";

		SELECT first 1 upper(plan)
		  into _n_prod
		  FROM emipouni a, prdprod b
		 where a.cod_producto = b.cod_producto
		   and no_poliza      = _no_poliza
		   and no_unidad      = _no_unidad;		 
	   
		if _n_prod is null then
			let _n_prod = "";
		end if	   

		foreach
			select facturado,
				   elegible,
				   a_deducible,
				   co_pago,
				   coaseguro,
				   monto,
				   monto_no_cubierto,
				   ahorro,
				   cod_tipo,
				   cod_cobertura
			  into _gasto_fact,
				   _gasto_eleg,
				   _a_deducible,
				   _co_pago,
				   _coaseguro,
				   _pago_prov,
				   _gastos_no_cub,
				   _ahorro,
				   _cod_tipo,
				   _cod_cobertura
			  from rectrcob
			 where no_tranrec = _no_tranrec

			select exterior, nombre
			  into _exterior, _n_tipo
			  from prdticob
			 where cod_tipo = _cod_tipo;
			 
			select nombre
			  into _n_cobertura
			  FROM prdcober
		     WHERE cod_cobertura = _cod_cobertura;
			 
			if _cod_cobertura is null then
				let _cobertura_rec = '';
			else
				let _cobertura_rec = trim(_n_cobertura);
		    end if			 			 

			if _cod_tipo is null then
				let _tipo_rec = '';
			else
				let _tipo_rec = trim(_n_tipo);
			end if

			return _numrecla, _fecha_factura, _nombre_icd, _cod_cpt, _gasto_fact, _gastos_no_cub, _gasto_eleg, _a_deducible, _ahorro, _co_pago, _coaseguro, _pago_prov, _nombre_prov,
				   _cobertura_rec, _tipo_rec, _dependencia, _fecha_nac, _nombre_cont, _nombre_recla, _cod_contratante, _cod_reclamante, _nombre_cia, _cod_asegurado, _nombre_aseg,
				   _vigencia_inic, _vigencia_final, _filtro_ano, _filtro_aseg, _filtro_recla, _periodo, _cod_icd, _vig_ini_i, _vig_fin_i, _exterior, _n_prod,
				   _transaccion,_periodo_tran,_fecha_tran,_anio_factura,_mes_factura,_no_tranrec,_n_tipo_pago, _no_unidad with resume; 

		end foreach
	end foreach
end foreach
end procedure;