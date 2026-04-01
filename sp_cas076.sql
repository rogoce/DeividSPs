-- Creado    : 27/07/2004 - Autor: Armando Moreno M.

drop procedure sp_cas076;

create procedure sp_cas076(a_cod_cliente char(10),a_no_documento char(20))
returning integer;

define _flag			integer;
define _no_documento    char(20);
define _no_poliza	    char(10);
define _cod_formapag    char(3);
define _tipo_forma	    smallint;

set isolation to dirty read;
let _flag = 1;

{let _no_poliza = sp_sis21(a_no_documento);

select cod_formapag
  into _cod_formapag
  from emipomae
 where no_poliza   = _no_poliza
   and actualizado = 1;

select tipo_forma
  into _tipo_forma
  from cobforpa
 where cod_formapag = _cod_formapag;

if _tipo_forma = 6 or _tipo_forma = 5 or _tipo_forma = 3 then 	--corredor,ancon,descuento directo
	let _flag = 1;
end if	}

RETURN _flag;

end procedure