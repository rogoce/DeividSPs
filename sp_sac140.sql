-- Cuadre de Auxiliares de la 26410 

-- Creado    : 13/09/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac140;

create procedure sp_sac140() 
returning char(5), 
          char(5),
          char(50),
          dec(16,2),
          dec(16,2),
          dec(16,2),
          char(2),
          dec(16,2),
          dec(16,2),
          dec(16,2);

define _cod_agente		char(5);
define _nombre			char(50);
define _saldo			dec(16,2);

define _cod_aux			char(5);
define _saldo_aux		dec(16,2);
define _cuenta			char(25);

define _no_requis		char(10);
define _no_documento 	char(20);

define _monto_cheque	dec(16,2);
define _tipo_error		char(2);

define _pagado			smallint;
define _anulado			smallint;
define _monto			dec(16,2);
define _monto_tot		dec(16,2);
define _prima_neta		dec(16,2);
define _prima_neta_tot	dec(16,2);
define _comision		dec(16,2);
define _comision_tot	dec(16,2);
define _porc_partic_agt	dec(5,2);
define _porc_comis_agt	dec(5,2);

SET ISOLATION TO DIRTY READ;

let _cuenta = "26410";

CALL sp_che02(
"001", 
"001",
"31/12/2009",
"31/12/2009"
);

let _tipo_error = "99";

foreach
 select codigo,
        nombre,
		saldo
   into _cod_agente,
        _nombre,
		_saldo
   from deivid_tmp:salagent200912
  order by 1

	select sum(comision)
	  into _comision
	  from tmp_agente
	 where cod_agente = _cod_agente;
	 
	if _comision is null then
		let _comision = 0.00;
	end if
	 
	let _cod_aux = "A" || _cod_agente[2,5];

	select sld1_saldo
	  into _saldo_aux
	  from cglsaldoaux1
	 where sld1_tipo    = "01"
	   and sld1_cuenta  = _cuenta
	   and sld1_tercero = _cod_aux
	   and sld1_ano     = "2009"
	   and sld1_periodo = 12;

	if _saldo_aux is null then
		let _saldo_aux = 0;
	end if

	let _saldo_aux = _saldo_aux * -1;

	return _cod_agente,
	       _cod_aux,
		   _nombre,
		   _saldo,
		   _saldo_aux,
		   _comision,
		   _tipo_error,
		   0.00,
		   0.00,
		   0.00
		   with resume;

end foreach

drop table tmp_agente;
 
{
foreach
 select cod_agente,
        nombre,
		saldo
   into _cod_agente,
        _nombre,
		_saldo
   from agtagent
--  where cod_agente = "00016"

	let _tipo_error = "99";

	let _cod_aux = "A" || _cod_agente[2,5];

	select sld1_saldo
	  into _saldo_aux
	  from cglsaldoaux1
	 where sld1_tipo    = "01"
	   and sld1_cuenta  = _cuenta
	   and sld1_tercero = _cod_aux
	   and sld1_ano     = "2009"
	   and sld1_periodo = 12;

	if _saldo_aux is null then
		let _saldo_aux = 0;
	end if

	let _saldo_aux = _saldo_aux * -1;

	if _saldo = _saldo_aux then
		continue foreach;
	end if

	let _prima_neta_tot = 0.00;
	let _monto_tot      = 0.00;
	let _comision_tot   = 0.00;

	foreach
	 select no_requis,
	        no_documento,
			porc_partic_agt,
			porc_comis_agt
	   into	_no_requis,
	        _no_documento,
			_porc_partic_agt,
			_porc_comis_agt
	   from chqchpoa
	  where cod_agente = _cod_agente

		select pagado,
		       anulado
		  into _pagado,
		       _anulado
		  from chqchmae
		 where no_requis = _no_requis;
		
		if _pagado = 0 then
			continue foreach;
		end if

		if _anulado = 1 then
			continue foreach;
		end if
			
		select monto,
		       prima_neta
		  into _monto,
		       _prima_neta
		  from chqchpol
		 where no_requis = _no_requis
		   and no_documento = _no_documento;

		let _comision       = _prima_neta * _porc_partic_agt/100 * _porc_comis_agt/100;

		let _prima_neta_tot = _prima_neta_tot + _prima_neta;
		let _monto_tot      = _monto_tot      + _monto;
		let _comision_tot   = _comision_tot   + _comision;

	end foreach
	 
	select sum(monto)
	  into _monto_cheque
	  from chqchmae
	 where cod_agente    = _cod_agente
	   and origen_cheque = "2"
	   and pagado        = 1
	   and anulado       = 0
	   and sac_asientos  <> 2;

	if _tipo_error = "99" and _comision_tot * -1 = _saldo and _saldo_aux = 0 and _saldo <> 0 then
		let _tipo_error = "10";
	end if

	if _tipo_error = "99" and _saldo_aux = 0 then
		let _tipo_error = "20";
	end if

	if _tipo_error = "99" and _saldo = 0 then
		let _tipo_error = "30";
	end if

	if _tipo_error = "99" and _comision_tot <> 0 then
		let _tipo_error = "40";
	end if

	if _tipo_error = "99" and _saldo = 0 and _saldo_aux = 0 then
		let _tipo_error = "98";
	end if



	if _tipo_error = "99" and _saldo = 0 and _saldo_aux = _monto_cheque then
		let _tipo_error = "20";
	end if

	return _cod_agente,
	       _cod_aux,
		   _nombre,
		   _saldo,
		   _saldo_aux,
		   _monto_cheque,
		   _tipo_error,
		   _monto_tot,
		   _prima_neta_tot,
		   _comision_tot
		   with resume;

end foreach
}

end procedure