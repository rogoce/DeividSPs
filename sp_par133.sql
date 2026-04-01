-- Procedimiento que muestra la provision de comision por pagar
-- 
-- Creado     : 28/12/2004 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par133;

create procedure "informix".sp_par133(
a_periodo1 char(7),
a_periodo2 char(7)
) returning char(50);

define _no_documento	char(20);
define _no_poliza		char(10);
define _cod_impuesto	char(3);

define _saldo			dec(16,2);

define _cod_tipoprod	char(3);
define _cod_ramo		char(3);
define _nombre_ramo		char(50);

define _cantidad		integer;
define _registros		integer;

DEFINE _fecha_anulado1	 DATE;
DEFINE _fecha_anulado2	 DATE;

define a_no_documento	char(20);
DEFINE _no_requis 		CHAR(10);
define a_periodo3		char(7);
define _ano_int			smallint;
define _mes_int			smallint;

--set debug file to "sp_par133.trc";
--trace on;

let a_no_documento = "0203-00428-23";

let _ano_int = a_periodo1[1,4];
let _mes_int = a_periodo1[6,7];

if _mes_int = 12 then
	let _mes_int = 1;
	let _ano_int = _ano_int + 1;
else
	let _mes_int = _mes_int + 1;
end if

if _mes_int < 10 then
	let a_periodo3 = _ano_int || "-0" || _mes_int;
else
	let a_periodo3 = _ano_int || "-" || _mes_int;
end if

set isolation to dirty read;

--delete from cobdifsa;

update cobdifsa
   set saldo2 = 0;

--{
foreach
 select no_documento
   into _no_documento
   from emipomae
  where actualizado = 1
--    and cod_tipoprod in ("001", "002", "005")
--  and cod_tipoprod in ("002")
--	and no_documento = a_no_documento
  group by no_documento

	let _no_poliza   = sp_sis21(_no_documento);

	select cod_tipoprod,
	       cod_ramo
	  into _cod_tipoprod,
	       _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "004" then -- Reaseguro Asumido
		continue foreach;
	end if

{
	let _saldo = sp_cob175(_no_documento, a_periodo1);

	if _saldo <> 0.00 then

		insert into cobdifsa
		values (_no_documento, _saldo, 0, 0, 0, 0);

	end if
}
	let _saldo = sp_cob175(_no_documento, a_periodo2);

	if _saldo <> 0.00 then

		select count(*)
		  into _cantidad
		  from cobdifsa
		 where no_documento = _no_documento;

		if _cantidad = 0 then
		  
			insert into cobdifsa
			values (_no_documento, 0, 0, 0, 0, _saldo);
		
		else
			
			update cobdifsa
			   set saldo2 = _saldo
			 where no_documento = _no_documento;

		end if

	end if

end foreach
--}

--{
update cobdifsa
   set facturas = 0,
       cobros   = 0,
	   cheques  = 0;

FOREACH
 SELECT sum(prima_bruta),
		no_poliza
   INTO _saldo,
		_no_poliza
   FROM endedmae
  WHERE cod_compania = "001"
    AND periodo     >= a_periodo3
    AND periodo     <= a_periodo2
	AND actualizado  = 1
	AND prima_bruta  <> 0 
  group by no_poliza
--	and no_documento = a_no_documento

	SELECT cod_tipoprod,
	       no_documento
	  INTO _cod_tipoprod,
	       _no_documento
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	IF _cod_tipoprod = "004" THEN
	 	CONTINUE FOREACH;
	END IF 	

	select count(*)
	  into _cantidad
	  from cobdifsa
	 where no_documento = _no_documento;

	if _cantidad = 0 then
	  
		insert into cobdifsa
		values (_no_documento, 0, _saldo, 0, 0, 0);

	else
		
		update cobdifsa
		   set facturas     = facturas + _saldo
		 where no_documento = _no_documento;

	end if

END FOREACH	
--}

-- Recibos 

--{
FOREACH
 SELECT	sum(monto),
        no_poliza
   INTO	_saldo,
        _no_poliza
   FROM	cobredet
  WHERE cod_compania = "001"
	AND actualizado = 1
	AND tipo_mov   IN ('P', 'N')
    AND periodo    >= a_periodo3
    AND periodo    <= a_periodo2
	AND monto      <> 0
  group by no_poliza
--	and doc_remesa = a_no_documento

	SELECT cod_tipoprod,
	       no_documento
	  INTO _cod_tipoprod,
	       _no_documento
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	IF _cod_tipoprod = "004" THEN
	 	CONTINUE FOREACH;
	END IF 	

	select count(*)
	  into _cantidad
	  from cobdifsa
	 where no_documento = _no_documento;

	if _cantidad = 0 then
	  
		insert into cobdifsa
		values (_no_documento, 0, 0, _saldo, 0, 0);

	else
		
		update cobdifsa
		   set cobros	    = cobros + _saldo
		 where no_documento = _no_documento;

	end if

END FOREACH
--}
-- Cheques Pagados

--{
FOREACH
 SELECT no_requis
   INTO _no_requis
   FROM chqchmae m
  WHERE m.pagado        = 1
    AND m.periodo      >= a_periodo3
    AND m.periodo      <= a_periodo2
	AND m.origen_cheque = "6"

   FOREACH	
	SELECT no_poliza,
		   monto
	  INTO _no_poliza,
	       _saldo
	  FROM chqchpol
	 WHERE no_requis    = _no_requis
--	   and no_documento = a_no_documento

		SELECT cod_tipoprod,
		       no_documento
		  INTO _cod_tipoprod,
		       _no_documento
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

		IF _cod_tipoprod = "004" THEN
		 	CONTINUE FOREACH;
		END IF 	

		select count(*)
		  into _cantidad
		  from cobdifsa
		 where no_documento = _no_documento;

		if _cantidad = 0 then
		  
			insert into cobdifsa
			values (_no_documento, 0, 0, 0, _saldo, 0);

		else
			
			update cobdifsa
			   set cheques	    = cheques + _saldo
			 where no_documento = _no_documento;

		end if

	END FOREACH

END FOREACH

-- Cheques Anulados

LET _fecha_anulado1 = MDY(a_periodo3[6,7], 1, a_periodo3[1,4]);

IF a_periodo2[6,7] = 12 THEN
	LET _fecha_anulado2 = MDY(1, 1, a_periodo2[1,4] + 1);
ELSE
	LET _fecha_anulado2 = MDY(a_periodo2[6,7] + 1, 1, a_periodo2[1,4]);
END IF

FOREACH
 SELECT no_requis
   INTO _no_requis
   FROM chqchmae m
  WHERE m.pagado        = 1
    AND m.fecha_anulado >= _fecha_anulado1
    AND m.fecha_anulado < _fecha_anulado2
	AND m.origen_cheque = "6"
	AND m.anulado       = 1

   FOREACH	
	SELECT no_poliza,
		   monto
	  INTO _no_poliza,
	       _saldo
	  FROM chqchpol
	 WHERE no_requis    = _no_requis
--	   and no_documento = a_no_documento

		SELECT cod_tipoprod,
		       no_documento
		  INTO _cod_tipoprod,
		       _no_documento
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

		IF _cod_tipoprod = "004" THEN
		 	CONTINUE FOREACH;
		END IF 	

		select count(*)
		  into _cantidad
		  from cobdifsa
		 where no_documento = _no_documento;

		let _saldo = _saldo * -1;

		if _cantidad = 0 then
		  
			insert into cobdifsa
			values (_no_documento, 0, 0, 0, _saldo, 0);

		else
			
			update cobdifsa
			   set cheques	    = cheques + _saldo
			 where no_documento = _no_documento;

		end if

	END FOREACH

END FOREACH
--}

return "Proceso Completado " ;

end procedure