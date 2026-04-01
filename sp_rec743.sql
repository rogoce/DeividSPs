-- Borderaux de Siniestros Pagados para el Reasegurador
-- Creado    : 24/02/2018 - Autor: Henry Giron
-- SIS v.2.0 - d_recl_sp_rec743_dw1 - DEIVID, S.A.
-- execute procedure sp_rec743('001','001','2010-11','2015-06',"*","*","*","*","*","*","1803-00505-01","18-1110-19528-10","*","22427")
drop procedure sp_rec743;

CREATE PROCEDURE "informix".sp_rec743(
a_compania	CHAR(3),
a_agencia	CHAR(3),
a_periodo1	CHAR(7),
a_periodo2	CHAR(7),
a_sucursal	CHAR(255) DEFAULT "*",
a_contrato	CHAR(255) DEFAULT "*",
a_ramo		CHAR(255) DEFAULT "*",
a_serie		CHAR(255) DEFAULT "*",
a_cober		CHAR(255) DEFAULT "*",
a_subramo	CHAR(255) DEFAULT "*",
a_documento CHAR(20)  DEFAULT "*",
a_numrecla  CHAR(20)  DEFAULT "*",
a_cod_asegurado char(10) default "*",
a_cod_reclamante char(10) default "*" )

returning char(20) 	as numrecla,	        -- 1
		  char(100) 	as nombre_icd,	    -- 2
		  char(100) 	as nombre_prov,	    -- 3
		  char(10)  as no_factura ,	        -- 23
		  date 	as fecha_siniestro,         -- 4
		  date	as fecha_pagado,            -- 5
		  dec(16,2) 	as gasto_fact,	    -- 6
		  dec(16,2) 	as gasto_eleg,	    -- 7
		  dec(16,2) 	as a_deducible,	    -- 8
		  dec(16,2) 	as co_pago,	        -- 9
		  dec(16,2) 	as coaseguro,	    -- 10
		  dec(16,2) 	as pago_prov,	    -- 11
		  int 	as no_cheque,               -- 12
		  date 	as fecha_cheque,            -- 13
		  char(20) 	as no_documento,        -- 14
		  char(50) 	as nombre_cia,	        -- 15
		  char(100) 	as nombre_cont,	    -- 16
		  char(100) 	as nombre_recla,	-- 17
		  smallint 	as serie_xls,           -- 18
		  date 	as vig_inic_xls,            -- 19
		  date 	as vig_final_xls,           -- 20
		  char(7) 	as periodo1,	        -- 21
		  char(7) 	as periodo2;            -- 22
          

define _numrecla		char(20);
define _no_documento    char(20);
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
define _dependencia,_desc_transaccion		char(100);
define _cod_parentesco  char(3);
define _no_tranrec		char(10);
define _cod_ramo        char(3);
define _no_requis       char(10);
define _no_cheque       int;
define _fecha_impresion date;
define _ahorro          dec(16,2);
define _mes             char(2);
define _ano             char(4);
define _ramo_sis		smallint;
define _nombre_icd		char(100);
define _fecha_factura   date;
define _cod_contrato		char(5);
define _cod_contrato_xls	char(5);
define _serie         	    smallint;
define _serie_xls        	smallint;
define _cod_cober_reas		char(3);
define _vig_inic_xls        date;
define _vig_final_xls       date;
define _fecha_captura       date;
define _filtros             char(255);
define _tipo                char(1);
define _transaccion         char(10);
define _no_fact             char(10);

--define _nombre_cpt		char(100);
set isolation to dirty read;

select cod_tipotran
  into _cod_tipotran
  from rectitra
 where tipo_transaccion = 4;

let _nombre_cia = trim(sp_sis01(a_compania));
let _nombre_recla = "" ;
let _nombre_aseg = "" ;
let _filtros =  "";

-- Descripcion de Filtros

if a_periodo1 = "*" then
	let _filtro_ano = "Todos los Años";
else
	let _filtro_ano = a_periodo1;
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

let _filtros = sp_rec704b(a_compania,a_agencia,a_periodo1,a_periodo2,a_sucursal,'*',a_ramo,'*','*','*','*',a_subramo,a_documento, a_numrecla);

{
update tmp_sinis
   set seleccionado = 0
 where doc_poliza in(select no_documento from reaexpol where activo = 1);  --Tabla para excluir polizas
}

IF a_documento <> "*" THEN
	update tmp_sinis
	   set seleccionado = 0
	 where doc_poliza <> a_documento;
END IF

IF a_numrecla <> "*" THEN
	update tmp_sinis
	   set seleccionado = 0
	 where numrecla <> a_numrecla;
END IF

-- Transacciones de Reclamos
FOREACH
	 select distinct no_tranrec,
			no_reclamo,
			doc_poliza,
			numrecla,
            transaccion,
            cod_ramo
	   into	_no_tranrec,
			_no_reclamo,
			_no_documento,
			_numrecla,
            _transaccion,
            _cod_ramo
	   FROM tmp_sinis
	  WHERE seleccionado = 1

FOREACH
	 select t.cod_cliente,
			t.fecha,
	        t.no_requis,
			t.ahorro,
			t.fecha_factura,
			r.cod_reclamante,
			t.no_tranrec, t.transaccion
	into 	_cod_proveedor,
	        _fecha_gasto,
			_no_requis,
			_ahorro,
			_fecha_factura,
			_cod_reclamante,
			_no_tranrec, _no_fact
	   from recrcmae r, rectrmae t
	 where r.no_reclamo   = t.no_reclamo
	   and r.no_documento = _no_documento
 	   and r.cod_reclamante matches a_cod_reclamante
	   and r.numrecla = _numrecla	   
       and t.cod_tipotran = _cod_tipotran	
	   and r.actualizado  = 1
	--   and t.pagado = 1  -- KCESAR 31/05/2018 adjuntar cheques no impresos
	   and t.anular_nt is null


		FOREACH
		select r.cod_contrato, r.cod_cober_reas, c.serie
		  into _cod_contrato, _cod_cober_reas, _serie
		  from recreaco r, reacomae c
		 where r.cod_contrato = c.cod_contrato
		   and r.no_reclamo = _no_reclamo
		   and c.tipo_contrato = 1
		   order by r.orden desc
		   EXIT FOREACH;
		END FOREACH

	 select	a.cod_icd,
			a.cod_cpt,
	        a.fecha_siniestro,
			a.cod_asegurado,
			a.no_unidad,
			a.no_poliza,
			a.periodo
	   into	_cod_icd,
			_cod_cpt,
	        _fecha_siniestro,
			_cod_contratante,
			_no_unidad,
			_no_poliza,
			_periodo
	   from recrcmae a
	  where	a.actualizado    = 1
		and a.cod_reclamante matches a_cod_reclamante
		and a.no_reclamo = _no_reclamo;

		select ramo_sis
		  into _ramo_sis
		  from prdramo
		 where cod_ramo = _cod_ramo;

		if _ramo_sis <> 5 then
		   continue foreach;
		end if

		select vigencia_inic,
		       vigencia_final
		  into _vigencia_inic,
		       _vigencia_final
		  from emipomae
		 where no_poliza = _no_poliza;

		IF _cod_icd is null OR _cod_icd = "" then

		   LET _nombre_icd = "";

		   FOREACH
			select desc_transaccion
			  into _desc_transaccion
			  from rectrde2
	 		 where no_tranrec = _no_tranrec

			IF _desc_transaccion is null then
				let _desc_transaccion = "";
			END IF

			LET _nombre_icd = TRIM(_nombre_icd) || TRIM(_desc_transaccion);
		   END FOREACH
			LET _cod_icd = "";
		ELSE
			select nombre
			  into _nombre_icd
			  from recicd
			 where cod_icd = _cod_icd;
		END IF

		IF _cod_cpt is null then
			let _cod_cpt = "";
		END IF

	{
		select nombre
		  into _nombre_cpt
		  from reccpt
		 where cod_cpt = _cod_cpt;
	}

		select trim(nombre)
		  into _nombre_cont
		  from cliclien
		 where cod_cliente = _cod_contratante;

		select trim(nombre)
		  into _nombre_recla
		  from cliclien
		 where cod_cliente = _cod_reclamante;

		let _cod_asegurado = null;

		foreach
		 select cod_cliente,
		        no_endoso
		   into _cod_asegurado,
		        _no_endoso
		   from endeduni
		  where no_poliza = _no_poliza
		    and no_unidad = _no_unidad
		  order by no_endoso desc
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

		select nombre
		  into _nombre_prov
		  from cliclien
		 where cod_cliente = _cod_proveedor;

		select no_cheque,
		       fecha_impresion,
			   fecha_captura
		  into _no_cheque,
		       _fecha_impresion,
			   _fecha_captura
		  from chqchmae
		 where no_requis = _no_requis;
   


		FOREACH
		select c.cod_contrato, a.serie,c.vigencia_inic , c.vigencia_final
		  into _cod_contrato_xls, _serie_xls, _vig_inic_xls, _vig_final_xls
		  from rearumae a, rearucon b, reacomae c, reacocob d
		 where a.cod_ramo = _cod_ramo
		   and _fecha_factura between a.vig_inic and a.vig_final
		   and b.cod_ruta = a.cod_ruta
		   and c.cod_contrato = b.cod_contrato
		   and d.cod_contrato = c.cod_contrato
		   and d.cod_cober_reas = _cod_cober_reas
		   and c.tipo_contrato = 1
		   and a.activo = 1
         order by a.serie desc
		   EXIT FOREACH;
		END FOREACH

		foreach
		 select	facturado,
		        elegible,
				a_deducible,
				co_pago,
				coaseguro,
				monto,
				monto_no_cubierto
		   into	_gasto_fact,
		        _gasto_eleg,
				_a_deducible,
				_co_pago,
				_coaseguro,
				_pago_prov,
				_gastos_no_cub
		   from rectrcob
		  where no_tranrec = _no_tranrec
    
       if _no_cheque = '0' or _no_cheque is null then
		   let _fecha_impresion = null;
           let _fecha_captura = null;
           let _no_cheque = 0;
      end if

		return _numrecla,	        -- 1
			   _nombre_icd,         -- 2
			   _nombre_prov,        -- 3
               _no_fact,             -- 23			   
			   _fecha_factura,      -- 4
			   _fecha_captura,      -- 5
			   _gasto_fact,         -- 6
			   _gasto_eleg,         -- 7
			   _a_deducible,        -- 8
			   _co_pago,            -- 9
			   _coaseguro,          -- 10
			   _pago_prov,          -- 11
			   _no_cheque,          -- 12
			   _fecha_impresion,    -- 13
			   _no_documento,       -- 14
			   _nombre_cia,         -- 15
			   _nombre_cont,        -- 16
			   _nombre_recla,       -- 17
			   _serie_xls,          -- 18
			   _vig_inic_xls,       -- 19
			   _vig_final_xls,      -- 20
			   a_periodo1,          -- 21
			   a_periodo2          -- 22
		  with resume;

		end foreach

	end foreach
end foreach

end procedure;