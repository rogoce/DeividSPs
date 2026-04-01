-- Procedure que determina cuales facturas han cambiado
-- desde que se crearon

-- Creado    : 31/07/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 31/07/2002 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_a;

create procedure sp_a()
returning char(20),
          char(10);

define _no_poliza,_cod_asignacion		  char(10);
define _no_documento      char(20);
define _cod_impuesto      char(3);
define _cnt				  integer;
define _monto             dec(16,2);
define _prima_bruta       dec(16,2);
define _impuesto       dec(16,2);
define _imp        dec(16,2);
define _por_vencer dec(16,2);
define _exigible   dec(16,2);
define _corr	   dec(16,2);
define _monto30	   dec(16,2);
define _monto60	   dec(16,2);
define _monto90	   dec(16,2);
define _saldo	   dec(16,2);
define _cod_tipoprod char(3);

let _cnt = 0;
let _monto = 0;
let _prima_bruta = 0;
let _impuesto = 0;

set isolation to dirty read;


{foreach

	select e.no_poliza
	  into _no_poliza
	from emirepo e, emideren t
	where e.no_poliza = t.no_poliza
	and t.renglon = 9
	and e.user_added = 'SLEE'

	update emirepo
	set user_added = 'AHILL'
	where no_poliza = _no_poliza;

end foreach}

{foreach
	select no_poliza
	  into _no_poliza
	 from cobaviso
	where cod_cobrador = '151'
	and tipo_aviso = 1
	and impreso = 1

	update emipomae
	   set fecha_aviso_canc = today,
	       carta_aviso_canc = 1
	 where no_poliza = _no_poliza;

end foreach}

{foreach

select cod_asignacion,
       no_documento
  into _cod_asignacion,
	   _no_documento
  from atcdocde
 where fec_libero_mora = '14/07/2010'


		call sp_cob33 ('001', '001', _no_documento, '2010-07', '14/07/2010') returning _por_vencer,_exigible,_corr,_monto30,_monto60,_monto90,_saldo;

		if _monto30 > 0 then

		   	update atcdocde
				set en_mora       = 1,
					user_mora     = '',
					obs_mora      = ''
			 where cod_asignacion = _cod_asignacion;

			return _no_documento,_cod_asignacion with resume;

		end if

end foreach	}

foreach

select no_poliza,doc_remesa
  into _no_poliza,_no_documento
  from cobredet
 where no_remesa = '404799'
   and prima_neta = 0.01

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod <> "001" then
	else
	   return _no_documento,'';		
	end if

end foreach


end procedure

