-- Actualizacion de los registros de morosidad y cobros para BO

-- Creado    : 28/08/2006 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_par236; 

create procedure "informix".sp_par236(a_periodo1 char(7), a_periodo2 char(7)) 
returning char(20),
            dec(16,2),
            dec(16,2),
            dec(16,2),
            dec(16,2),
            dec(16,2),
            dec(16,2),
            dec(16,2);

define _no_poliza		char(10);
define _no_endoso		char(5);
define _cod_tipoprod	char(3);
define _no_remesa		char(10);
define _renglon			integer;

define _no_documento	char(20);
define _saldo1			dec(16,2);
define _facturas		dec(16,2);
define _cobros			dec(16,2);
define _cheques			dec(16,2);
define _saldo2			dec(16,2);
define _saldo_calc		dec(16,2);
define _diferencia		dec(16,2);

set isolation to dirty read;

create temp table tmp_sac(
no_documento	char(20),
cod_tipoprod	char(3),
saldo1			dec(16,2),
facturas		dec(16,2),
cobros			dec(16,2),
cheques			dec(16,2),
saldo2			dec(16,2)
) with no log;


-- Saldo Inicial

foreach
 select no_documento,
		no_poliza,
        saldo_pxc
   into _no_documento,
        _no_poliza,
        _saldo1
   from cobmoros
  where periodo = a_periodo1 
--    and no_documento = "1197-0045-01"

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod <> "002" then
		let _cod_tipoprod = "005";
	end if

	insert into tmp_sac
	values (_no_documento, _cod_tipoprod, _saldo1, 0, 0, 0, 0);

end foreach

-- Facturas

foreach
 select no_poliza,
        no_endoso
   into _no_poliza,
        _no_endoso
   from endedmae
  where actualizado = 1
    and periodo     = a_periodo2
--    and no_documento = "1197-0045-01"

	select cod_tipoprod,
	       no_documento
	  into _cod_tipoprod,
	       _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "002" then

		select sum(debito + credito)
		  into _facturas
		  from endasien
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		   and cuenta like "144%";

	else

		let _cod_tipoprod = "005";

		select sum(debito + credito)
		  into _facturas
		  from endasien
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		   and cuenta like "131%";

	end if

	insert into tmp_sac
	values (_no_documento, _cod_tipoprod, 0, _facturas, 0, 0, 0);

end foreach

-- Cobros

foreach
 select no_poliza,
        no_remesa,
		renglon
   into _no_poliza,
        _no_remesa,
		_renglon
   from cobredet
  where actualizado = 1
    and periodo     = a_periodo2
	and tipo_mov in ("P", "N")
--    and doc_remesa = "1197-0045-01"

	select cod_tipoprod,
	       no_documento
	  into _cod_tipoprod,
	       _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "002" then

		select sum(debito - credito)
		  into _cobros
		  from cobasien
		 where no_remesa = _no_remesa
		   and renglon   = _renglon
		   and cuenta like "144%";

	else

		let _cod_tipoprod = "005";

		select sum(debito - credito)
		  into _cobros
		  from cobasien
		 where no_remesa = _no_remesa
		   and renglon   = _renglon
		   and cuenta like "131%";

	end if

	insert into tmp_sac
	values (_no_documento, _cod_tipoprod, 0, 0, _cobros, 0, 0);

end foreach

-- Cheques Pagados

foreach
 select p.no_poliza,
        p.no_documento,
		p.prima_neta
   into _no_poliza,
        _no_documento,
		_cheques
   from chqchpol p, chqchmae c
  where c.pagado =  1
    and c.no_requis = p.no_requis
    and c.periodo   = a_periodo2
--    and no_documento = "1197-0045-01"

	select cod_tipoprod,
	       no_documento
	  into _cod_tipoprod,
	       _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod <> "002" then
		let _cod_tipoprod = "005";
	end if

	insert into tmp_sac
	values (_no_documento, _cod_tipoprod, 0, 0, 0, _cheques, 0);

end foreach

-- Cheques Anulados

foreach
 select p.no_poliza,
        p.no_documento,
		p.prima_neta * -1
   into _no_poliza,
        _no_documento,
		_cheques
   from chqchpol p, chqchmae c
  where c.pagado               =  1
    and c.no_requis            = p.no_requis
    and year(c.fecha_anulado)  = a_periodo2[1,4]
    and month(c.fecha_anulado) = a_periodo2[6,7]

	select cod_tipoprod,
	       no_documento
	  into _cod_tipoprod,
	       _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod <> "002" then
		let _cod_tipoprod = "005";
	end if

	insert into tmp_sac
	values (_no_documento, _cod_tipoprod, 0, 0, 0, _cheques, 0);

end foreach

-- Saldo Final

foreach
 select no_documento,
		no_poliza,
        saldo_pxc
   into _no_documento,
        _no_poliza,
        _saldo2
   from cobmoros
  where periodo = a_periodo2
--    and no_documento = "1197-0045-01"

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod <> "002" then
		let _cod_tipoprod = "005";
	end if

	insert into tmp_sac
	values (_no_documento, _cod_tipoprod, 0, 0, 0, 0, _saldo2);

end foreach

foreach
 select no_documento,
        cod_tipoprod,
        sum(saldo1),
		sum(facturas),
		sum(cobros),
		sum(cheques),
		sum(saldo2)
   into _no_documento,
        _cod_tipoprod,
        _saldo1,
		_facturas,
		_cobros,
		_cheques,
		_saldo2
   from tmp_sac
  group by cod_tipoprod, no_documento 
  order by cod_tipoprod, no_documento

	if _cod_tipoprod = "002" then
		continue foreach;
	end if

	let _saldo_calc = _saldo1 + _facturas + _cobros + _cheques;
	let _diferencia = _saldo_calc - _saldo2;

	if abs(_diferencia) <> 0.00 then

		if _cheques <> 0.00 then

			return _no_documento,
			       _saldo1,
				   _facturas,
				   _cobros,
				   _cheques,
				   _saldo2,
				   _saldo_calc,
				   _diferencia
				   with resume;

		end if

	end if

end foreach

drop table tmp_sac;

end procedure
