-- CONSULTA DE PRIMAS POR COBRAR
-- Procedimiento que extrae los Saldos de la Poliza
-- usado en carta declarativa de salud.
 
-- Creado    : 26/01/2004 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_atc03a;

CREATE PROCEDURE "informix".sp_atc03a(a_compania CHAR(3),a_sucursal CHAR(3),a_agente CHAR(10),a_ano integer, a_usuario CHAR(10), a_membrete SMALLINT DEFAULT 0)
RETURNING	CHAR(20),
			VARCHAR(100),
			SMALLINT;{, -- PAGADOR
			DEC(16,2),    -- SALDO
			VARCHAR(30),  -- CEDULA
			VARCHAR(100), -- ASEGURADO
			VARCHAR(50),  -- NOMBRE RAMO
			SMALLINT,	  -- FLAG
			DEC(16,2),	  -- FACTURADO
			DEC(16,2),	  -- MONTO
			CHAR(1),	  -- TIPO PERSONA
			CHAR(10),	  -- USUARIO
			SMALLINT,	  -- AGNO
			VARCHAR(20),
			VARCHAR(20),
			VARCHAR(30),
			VARCHAR(50),
			DEC(16,2),	  -- MONTO NO CUBIERTO
			CHAR(10),
			DATETIME HOUR TO SECOND;}


DEFINE v_fecha		      	DATE;
DEFINE v_fecha_min        	DATE;
DEFINE v_fecha_max        	DATE;
DEFINE _fecha_factura     	DATE;
DEFINE v_referencia       	CHAR(20);
DEFINE v_documento        	CHAR(20);
DEFINE v_monto            	DEC(16,2);
DEFINE v_prima            	DEC(16,2);
DEFINE v_saldo            	DEC(16,2);	 
DEFINE v_periodo          	CHAR(7);
DEFINE v_cod_endomov      	CHAR(3);
DEFINE v_cod_tipocan      	CHAR(3);
DEFINE _cod_tipoprod      	CHAR(3);

DEFINE _no_poliza        	CHAR(10);
DEFINE _cod_contratante  	CHAR(10);
DEFINE _cod_pagador      	CHAR(10);
DEFINE _tipo_fac         	CHAR(30);
DEFINE _nueva_renov      	CHAR(1);
DEFINE _tipo_remesa      	CHAR(1);
DEFINE _no_requis		 	CHAR(10);
DEFINE _no_remesa		 	CHAR(10);
DEFINE _pagado           	SMALLINT;
DEFINE _anulado          	SMALLINT;
DEFINE _ramo_sis	     	SMALLINT;
DEFINE _cod_banco        	CHAR(3);
DEFINE _cod_ramo	     	CHAR(3);
define _nombre_asegurado 	varchar(100);
define _nombre_ramo		 	varchar(50);
define _nombre_pagador   	varchar(100);
define _flag			 	smallint;
define _saber_cobro		 	smallint;
define _saber_reclamo	 	smallint;
define _sindato			 	smallint;
define _cod_tipotran    	char(3);
define _fecha_gasto			date;
define _periodo				char(7);
define _no_tranrec			char(10);
define _no_reclamo			char(10);
define _numrecla			char(20);
define _fecha_siniestro		date;
define _no_unidad			char(10);
define _gasto_fact			dec(16,2);
define _pago_prov			dec(16,2);
define _monto_no_cubierto	dec(16,2);
define v_fecha_rec_min  	date;
define v_fecha_rec_max		date;
define _tipo_persona    	CHAR(1);
define _cedula          	varchar(30);
define v_firma_cartas		varchar(20);
define v_cedula_cartas		varchar(20);
define v_nombre_completo 	varchar(30);
define v_cargo           	varchar(50);
define _no_documento        CHAR(20);
define _cantidad			smallint;	
define _no_unidad2          CHAR(5);
define v_fecha_genera       DATETIME HOUR TO SECOND;
define _agno                CHAR(4);

SET ISOLATION TO DIRTY READ;

--DROP TABLE tmp_saldo1;

let _agno = a_ano;
let _flag = 0;
let _saber_reclamo = 0;
let _saber_cobro   = 0;
let _sindato       = 0;

{CREATE TEMP TABLE tmp_saldo1(
        fecha           DATE,
		referencia      CHAR(20),
		no_documento    CHAR(20),
		monto           DEC(16,2),
		prima_neta      DEC(16,2),
		periodo			CHAR(7),
		no_poliza       CHAR(10),
		tipo_fac        CHAR(30)
		) WITH NO LOG;

CREATE TEMP TABLE tmp_rec1(
        fecha           	DATE,
		facturado       	DEC(16,2),
		pagado		    	DEC(16,2),
		monto_no_cubierto 	DEC(16,2),
		no_poliza           CHAR(10)
		) WITH NO LOG; }  

CREATE TEMP TABLE tmp_rec2(
        fecha           	DATE,
		facturado       	DEC(16,2),
		pagado		    	DEC(16,2),
		monto_no_cubierto 	DEC(16,2),
		no_poliza           CHAR(10),
		no_unidad           CHAR(5),
		cod_asegurado       CHAR(10),
		seleccionado		SMALLINT DEFAULT 1
		) WITH NO LOG;   

-- SET DEBUG FILE TO "sp_atc03.trc";      
-- TRACE ON;                                                                     


foreach	with hold
 select a.no_poliza,
        a.nueva_renov,
		a.cod_ramo,
		a.no_documento
   into _no_poliza,
        _nueva_renov,
		_cod_ramo,
		_no_documento
   from emipomae a, emipoagt b, prdramo c
  where a.no_poliza  = b.no_poliza
    and a.cod_ramo   = c.cod_ramo
    and b.cod_agente = a_agente
    and a.actualizado  = 1
	and c.ramo_sis     = 5

 select count(*)
   into _cantidad
   from emipouni
  where no_poliza = _no_poliza;

 	if _cantidad > 1 then
		continue foreach;
	end if

 if _cantidad = 1 then
	 let _flag = 1;
 	 select cod_contratante
 	   into _cod_pagador
	   from emipomae
	  where no_poliza = _no_poliza;

	 select nombre
	   into _nombre_pagador
	   from cliclien
	  where cod_cliente = _cod_pagador;

     select cod_asegurado
	   into _cod_contratante
	   from emipouni
	  where no_poliza = _no_poliza;

	 select nombre,
			cedula,
			tipo_persona
	   into _nombre_asegurado,
	        _cedula,
			_tipo_persona
	   from cliclien
	  where cod_cliente = _cod_contratante;

	 select nombre,
			ramo_sis
	   into _nombre_ramo,
			_ramo_sis
	   from prdramo
	  where cod_ramo = _cod_ramo;

	
	return _no_documento,
	       _nombre_pagador,
	       0{,
		   abs(v_monto),
		   trim(_cedula),
		   trim(_nombre_asegurado),
		   trim(_nombre_ramo),
		   _flag,
		   _gasto_fact,
		   _pago_prov,
		   _tipo_persona,
		   a_usuario,
		   a_ano,
		   trim(v_firma_cartas),
		   trim(v_cedula_cartas),
		   trim(v_nombre_completo),
		   trim(v_cargo),
		   _monto_no_cubierto,
		   _no_poliza,
		   v_fecha_genera}
  	   	   with resume;
  else
  	let _flag = 0;
	 select cod_ramo,
	        cod_contratante
	   into _cod_ramo,
	        _cod_pagador
	   from emipomae
	  where no_poliza = _no_poliza;

	 select nombre
	   into _nombre_pagador
	   from cliclien
	  where cod_cliente = _cod_pagador;

	 foreach
	     select no_unidad,
		        cod_asegurado
		   into _no_unidad2,
		       	_cod_contratante
		   from emipouni
		  where activo = 1
		    and no_poliza = _no_poliza

		 select nombre,
				ramo_sis
		   into _nombre_ramo,
				_ramo_sis
		   from prdramo
		  where cod_ramo = _cod_ramo;

		 let _monto_no_cubierto = 0.00;

		 if _ramo_sis <> 5 then		--si no es salud
			let _pago_prov  = 0;
			let _gasto_fact = 0;
		 else
			select cod_tipotran
			  into _cod_tipotran
			  from rectitra
			 where tipo_transaccion = 4;

	        select count(*)
			  into _cantidad
			  from recrcmae
			 where no_documento   = _no_documento
			   and actualizado    = 1
			   and no_unidad      = _no_unidad2;

			if _cantidad > 0 then 
				foreach
				 select	numrecla,
				        fecha_siniestro,
						no_reclamo,
						no_unidad,
						no_poliza,
						periodo
				   into	_numrecla,
				        _fecha_siniestro,
						_no_reclamo,
						_no_unidad,
						_no_poliza,
						_periodo
				   from recrcmae
				  where	no_documento   = _no_documento
				    and actualizado    = 1
					and no_unidad      = _no_unidad2

					foreach
						 select fecha,
								no_tranrec,
								fecha_factura
						   into	_fecha_gasto,
								_no_tranrec,
								_fecha_factura
						   from rectrmae
						  where no_reclamo   = _no_reclamo
						    and actualizado  = 1
							and cod_tipotran = _cod_tipotran

						 select	sum(facturado),
								sum(monto),
								sum(monto_no_cubierto)
						   into	_gasto_fact,
								_pago_prov,
								_monto_no_cubierto
						   from rectrcob
						  where no_tranrec = _no_tranrec;

						if _fecha_factura is null then
							let _fecha_factura = _fecha_gasto;
						end if

						-- en vez de fecha de la transaccion de puso fecha de factura
						-- solicitado por maruquel el 06/02/2007
						-- cambiado por demetrio hurtado

						insert into tmp_rec2(
						fecha,
						facturado,
						pagado,
						monto_no_cubierto,
						no_unidad,
						cod_asegurado,
						no_poliza
						)
						values(
						_fecha_factura,
						_gasto_fact,
						_pago_prov,
						_monto_no_cubierto,
						_no_unidad,
						_cod_contratante,
						_no_poliza
					    );
					end foreach
				end foreach
			else
				insert into tmp_rec2(
				fecha,
				facturado,
				pagado,
				monto_no_cubierto,
				no_unidad,
				cod_asegurado,
				no_poliza
				)
				values(
				date("01/01/"||_agno),
				_gasto_fact,
				_pago_prov,
				_monto_no_cubierto,
				_no_unidad2,
				_cod_contratante,
				_no_poliza
			    );
			end if
	 	 end if
	 end foreach

    let v_fecha_genera = current;

	foreach	with hold
		select sum(facturado),
			   sum(pagado),
			   sum(monto_no_cubierto),
			   no_unidad,
			   cod_asegurado,
			   no_poliza
		  into _gasto_fact,
			   _pago_prov,
			   _monto_no_cubierto,
			   _no_unidad,
			   _cod_contratante,
			   _no_poliza
		  from tmp_rec2
		 where year(fecha) = a_ano
		   and seleccionado = 1
		 group by no_poliza, no_unidad, cod_asegurado

        select no_documento
		  into _no_documento
		  from emipomae
		 where no_poliza = _no_poliza;


	    let v_fecha_genera = v_fecha_genera + 1 units second;

		return _no_documento,
		       _nombre_pagador,
		       0{,
		       0.00,
			   trim(_cedula),
			   trim(_nombre_asegurado),
			   trim(_nombre_ramo),
			   _flag,
	  		   _gasto_fact,
			   _pago_prov,
			   _tipo_persona,
			   a_usuario,
			   a_ano,
			   trim(v_firma_cartas),
			   trim(v_cedula_cartas),
			   trim(v_nombre_completo),
			   trim(v_cargo),
			   _monto_no_cubierto,
			   _no_poliza,
			   v_fecha_genera}
			   with resume;
	end foreach

  end if

--delete from tmp_saldo1;
--delete from tmp_rec1;
delete from tmp_rec2;

end foreach

--drop table tmp_saldo1;
--drop table tmp_rec1;
drop table tmp_rec2;

end procedure