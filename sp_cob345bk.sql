-- Procedimiento que Genera la verificacion de las primas por cobrar
-- 
-- Creado    : 28/11/2000 - Autor: Demetrio Hurtado Almanza
-- modificado: 28/11/2000 - Autor: Demetrio Hurtado Almanza
-- 
-- SIS v.2.0 - DEIVID, S.A.


drop procedure sp_cob345bk;
create procedure "informix".sp_cob345bk(a_periodo char(7)) 
returning	char(20),
            dec(16,2),
            dec(16,2),
            dec(16,2),
            dec(16,2),
            dec(16,2),
            dec(16,2),
            dec(16,2),
            dec(16,2),
            dec(16,2),
			char(7),
			char(20);

define _saldo_act		dec(16,2);
define _saldo_ant		dec(16,2);
define _saldo_dif		dec(16,2);
define _movim_dif		dec(16,2);
define _total_dif		dec(16,2);
define _period_ant		char(7);
define _ano				smallint;
define _mes				smallint;

define _no_documento	char(20);
define _no_poliza		char(10);
define _porc_impuesto	dec(16,2);

define _produccion		dec(16,2);
define _cobros			dec(16,2);
define _cheq_pag		dec(16,2);
define _cheq_anu		dec(16,2);
define _tipo_prod_c     char(20);
define _tipo_prod       smallint;

let _ano		  = a_periodo[1,4];
let _mes		  = a_periodo[6,7];
let _period_ant   = sp_sis147(a_periodo);


--let _no_documento = '0210-00246-01';--"2013-00138-01";

create temp table tmp_cuadre_pxc(
no_documento	char(20),
saldo_ant		dec(16,2) default 0,
saldo_act		dec(16,2) default 0,
saldo_dif		dec(16,2) default 0,
produccion		dec(16,2) default 0,
cobros			dec(16,2) default 0,
cheq_pag		dec(16,2) default 0,
cheq_anu		dec(16,2) default 0
) with no log;

foreach
 select no_documento
   into _no_documento
   from emipoliza
--  where no_documento IN('1014-00116-01','1415-00026-01','0210-00246-01')--= _no_documento

	let _saldo_act = sp_cob175(_no_documento, a_periodo);
	let _saldo_ant = sp_cob175(_no_documento, _period_ant);

	--{
	if _saldo_act <> 0 or _saldo_ant <> 0 then
	
		let _no_poliza = sp_sis21(_no_documento);
		
		select sum(i.factor_impuesto)
		  into _porc_impuesto
		  from emipolim p, prdimpue i
		 where p.cod_impuesto = i.cod_impuesto
		   and p.no_poliza    = _no_poliza;  

		if _porc_impuesto is null then
			let _porc_impuesto = 0.00;
		end if

		let _saldo_act = _saldo_act	/ (1 + (_porc_impuesto / 100));
		let _saldo_ant = _saldo_ant	/ (1 + (_porc_impuesto / 100));

	end if
	--}

	insert into tmp_cuadre_pxc(
	       no_documento,
		   saldo_ant,
		   saldo_act,
		   saldo_dif
		   )
		   values(
		   _no_documento,
	       _saldo_ant,
		   _saldo_act,
		   _saldo_act - _saldo_ant
		   );
end foreach

-- Produccion

foreach
 select no_documento,
        prima_neta
   into _no_documento,
        _produccion
   from endedmae
  where cod_compania = "001"
    and actualizado  = 1
    and periodo      = a_periodo
--	and no_documento IN('1014-00116-01','1415-00026-01','0210-00246-01')--= _no_documento

	insert into tmp_cuadre_pxc(
	       no_documento,
		   produccion
		   )
		   values(
		   _no_documento,
	       _produccion
		   );

end foreach

-- Cobros

foreach
 select doc_remesa,
        prima_neta
   into _no_documento,
        _cobros
   from cobredet
  where cod_compania = "001"
    and actualizado  = 1
	and tipo_mov     in ("P", "N", "X")
    and periodo      = a_periodo
--	and doc_remesa   IN('1014-00116-01','1415-00026-01','0210-00246-01')--= _no_documento

	insert into tmp_cuadre_pxc(
	       no_documento,
		   cobros
		   )
		   values(
		   _no_documento,
	       _cobros
		   );

end foreach

-- Cheques Pagados

foreach
 select p.no_documento,
        p.prima_neta
   into _no_documento,
        _cheq_pag
   from chqchpol p, chqchmae m
  where p.no_requis              = m.no_requis
    and m.pagado                 = 1
    and year(m.fecha_impresion)  = _ano
    and month(m.fecha_impresion) = _mes
--	and p.no_documento           IN('1014-00116-01','1415-00026-01','0210-00246-01')--= _no_documento

	insert into tmp_cuadre_pxc(
	       no_documento,
		   cheq_pag
		   )
		   values(
		   _no_documento,
	       _cheq_pag
		   );

end foreach

-- Cheques Anulados

foreach
 select p.no_documento,
        p.prima_neta
   into _no_documento,
        _cheq_anu
   from chqchpol p, chqchmae m
  where p.no_requis              = m.no_requis
    and m.pagado                 = 1
    and m.anulado                = 1
    and year(m.fecha_anulado)    = _ano
    and month(m.fecha_anulado)   = _mes
--	and p.no_documento           IN('1014-00116-01','1415-00026-01','0210-00246-01')--= _no_documento

	insert into tmp_cuadre_pxc(
	       no_documento,
		   cheq_anu
		   )
		   values(
		   _no_documento,
	       _cheq_anu
		   );

end foreach

foreach
 select no_documento,
        sum(saldo_ant),
		sum(saldo_act),
		sum(saldo_dif),
		sum(produccion),
		sum(cobros),
		sum(cheq_pag),
		sum(cheq_anu)
   into _no_documento,
	    _saldo_ant,
		_saldo_act,
		_saldo_dif,
		_produccion,
		_cobros,
		_cheq_pag,
		_cheq_anu
   from tmp_cuadre_pxc
  group by 1

	if _saldo_ant  = 0 and
	   _saldo_act  = 0 and
	   _produccion = 0 and
	   _cobros     = 0 and
	   _cheq_pag   = 0 then

		continue foreach;

	end if

	let _cheq_pag  = _cheq_pag   - _cheq_anu;
	let _movim_dif = _produccion - _cobros + _cheq_pag;
	let _total_dif = _saldo_dif  - _movim_dif;


	if abs(_total_dif) > 0.05 then
		let _cheq_anu = 1;
	else
		let _cheq_anu = 0;
	end if
	
	let _no_poliza = sp_sis21(_no_documento);
	let _tipo_prod = sp_sis437(_no_poliza);	--Buscar tipo de Produccion
	if _tipo_prod = 3 then	--Coas. MINORITARIO
		let _tipo_prod_c = 'COAS. MINORITARIO';
	else
		let _tipo_prod_c = 'PROD. DIRECTA';
	end if	
	return _no_documento,
	       _saldo_ant,
		   _saldo_act,
		   _saldo_dif,
		   _produccion,
		   _cobros,
		   _cheq_pag,
		   _cheq_anu,
		   _movim_dif,
		   _total_dif,
		   a_periodo,
		   _tipo_prod_c
		   with resume;

end foreach

drop table tmp_cuadre_pxc;

{return "",
       0,
	   0,
	   0,
	   0,
	   0,
	   0,
	   0,
	   0,
	   0,
	   a_periodo,_tipo_prod_c;}

end procedure