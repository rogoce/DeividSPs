-- Hoja de Auditoria para Reclamos de Salud (Para Pago de Reclamos)

-- Creado    : 20/04/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - d_recl_sp_rec83_dw1 - DEIVID, S.A.

drop procedure sp_che61b;

create procedure sp_che61b(a_compania char(3),a_cheque integer)
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
		  char(7),				
		  char(50),
		  char(100),
		  char(100),
		  date,
		  char(20),
		  char(3),
		  date,
		  date,
		  char(10),
		  char(10),
		  integer,
		  dec(16,2),
		  dec(16,2);

define _ded_local       dec(16,2);
define _numrecla		char(20);
define _no_documento	char(20);
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
define _cod_tipotran    char(3);
define _fecha_gasto		date;
define _periodo			char(7);
define _dependencia		char(50);
define _cod_parentesco  char(3);
define _transaccion		char(10);
define _no_tranrec		char(10);
define _nombre_icd		char(100);
define _nombre_cpt		char(100);
define _cod_no_cubierto	char(3);
define _fecha_factura	date;
define _fecha_desde		date;
define _fecha_hasta		date;
define v_fecha_desde	date;
define v_fecha_hasta	date;
define _cod_banco		char(3);
define _cod_chequera	char(3);
define _fecha_impresion date;
define _no_requis		char(10);
define _no_cheque       integer;
define _valor			integer;
define _fecha_hoy       date;
define _ano_actual      char(4);
define _ano_ant         char(4);
define _ded_a_la_fecha  dec(16,2);
define _cnt             smallint;
define _cod_asignacion  char(10);

--set debug file to "sp_che61.trc";
--trace on;

set isolation to dirty read;

select cod_tipotran
  into _cod_tipotran
  from rectitra
 where tipo_transaccion = 4;

let _nombre_cia  = sp_sis01(a_compania);
 
--let _valor       = sp_che61a(a_compania,a_requis);
let _cnt = 0;
let _ded_a_la_fecha = 0;
let _fecha_hoy      = today;
let _ano_actual     = year(_fecha_hoy);
let _ano_ant        = year(_fecha_hoy) - 1;
		
select cod_banco,
       cod_chequera
  into _cod_banco,
	   _cod_chequera
  from chqbanch
 where cod_ramo = '018';

foreach
 select	no_requis,
		fecha_impresion,
		no_cheque
   into	_no_requis,
		_fecha_impresion,
		_no_cheque
   from chqchmae
  where pagado        = 1
    and anulado       = 0
	and origen_cheque = "3"
	and cod_banco	  = _cod_banco
	and cod_chequera  = _cod_chequera
	and en_firma      = 2
	and autorizado    = 1
	and no_cheque     = a_cheque

--	and fecha_impresion = today
	let _no_requis = trim(_no_requis);

	
	foreach
		select numrecla,
			   transaccion
		  into _numrecla,
			   _transaccion
		  from chqchrec
		 where no_requis = _no_requis
		 order by 1

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
		  where	numrecla = _numrecla

			SELECT p.deducible_local
			  into _ded_local
			  FROM prdprod p, emipouni a
			 WHERE a.cod_producto = p.cod_producto 
			   AND a.no_poliza    = _no_poliza
			   AND a.no_unidad    = _no_unidad;

			if _ded_local is null then
				let _ded_local = 0;
			end if

			select vigencia_inic,
			       vigencia_final,
				   no_documento
			  into _vigencia_inic,
			       _vigencia_final,
				   _no_documento
			  from emipomae
			 where no_poliza = _no_poliza;

			select count(*)
			  into _cnt
			  from recacuan
			 where no_documento = _no_documento
			   and ano          = _ano_actual
			   and cod_cliente  = _cod_reclamante;

			let _ded_a_la_fecha = 0;

			if _cnt > 0 then

				select monto_deducible
				  into _ded_a_la_fecha
				  from recacuan
				 where no_documento = _no_documento
				   and ano          = _ano_actual
				   and cod_cliente  = _cod_reclamante;

			else
				let _ded_a_la_fecha	= 0; -->> Si no encuentra movimientos, debe ser 0 -- Amado 30/06/2009
{				select monto_deducible
				  into _ded_a_la_fecha
				  from recacuan
				 where no_documento = _no_documento
				   and ano          = _ano_ant
				   and cod_cliente  = _cod_reclamante;
}
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

			-- Transacciones de Reclamos
			 select min(fecha_factura),
			        max(fecha_factura)
			   into	v_fecha_desde,
					v_fecha_hasta
			   from rectrmae
			  where transaccion   = _transaccion
			    and actualizado   = 1
				and cod_tipotran  in("004","013")
				and year(fecha_factura) in(_ano_actual,_ano_ant);

			foreach
			 select cod_proveedor,
					fecha,
					cod_cpt,
					no_tranrec,
					fecha_factura,
					cod_tipotran,
					cod_asignacion
			   into	_cod_proveedor,
					_fecha_gasto,
					_cod_cpt,
					_no_tranrec,
					_fecha_factura,
					_cod_tipotran,
					_cod_asignacion
			   from rectrmae
			  where transaccion  = _transaccion
			    and actualizado  = 1
				and year(fecha_factura) in(_ano_actual,_ano_ant)

				if _cod_tipotran not in("004","013") then
					continue foreach;
				else
					if _cod_tipotran = "013" then	--declinacion
						select count(*)
						  into _cnt
						  from rectrmae
						 where cod_asignacion = _cod_asignacion
						   and actualizado  = 1
						   --and cod_tipotran = "004"
						   and year(fecha_factura) in(_ano_actual,_ano_ant);
						 if _cnt > 0 then
						 else
							continue foreach;
						 end if
					end if
				end if

				if _cod_cpt is null then
					let _cod_cpt = "";
				end if

				select nombre
				  into _nombre_cpt
				  from reccpt
				 where cod_cpt = _cod_cpt;

				select nombre
				  into _nombre_prov
				  from cliclien
				 where cod_cliente = _cod_proveedor;

				foreach
				 select	facturado,
				        elegible,
						a_deducible,
						co_pago,
						coaseguro,
						monto,
						monto_no_cubierto,
						cod_no_cubierto
				   into	_gasto_fact,
				        _gasto_eleg,
						_a_deducible,
						_co_pago,
						_coaseguro,
						_pago_prov,
						_gastos_no_cub,
						_cod_no_cubierto
				   from rectrcob
				  where no_tranrec = _no_tranrec

					return _numrecla,		   -- 1
					       _fecha_siniestro,   -- 2
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
						   _periodo,		   -- 25
						   _dependencia,	   -- 26
						   _nombre_icd,		   -- 27	
						   _nombre_cpt,
						   _fecha_factura,
						   _no_documento,
						   _cod_no_cubierto,
						   v_fecha_desde,
						   v_fecha_hasta,
						   _no_tranrec,
						   _no_requis,
						   _no_cheque,
						   _ded_local,
						   _ded_a_la_fecha
						   with resume;

				end foreach

			end foreach

		end foreach

	end foreach

end foreach
end procedure;
