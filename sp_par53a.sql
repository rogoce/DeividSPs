-- Procedure que Verifica la Secuencia Numerica de
-- las tablas del Sistema

-- Creado    : 22/02/2002 - Autor: Demetrio Hurtado Almanza
-- Modificado: 22/02/2002 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_para_sp_par53_dw1 - DEIVID, S.A.

--drop procedure sp_par53a;

create procedure sp_par53a(a_periodo char(4)) 
returning char(100),char(20), smallint;

define _no_cheque	integer;
define _contador	integer;
define _no_recibo	char(20);
define _recibo1		integer;
define _recibo2		integer;
define _diferencia	integer;
define _mensaje		char(100);
define _tipo		char(20);

define _pol_suc		char(2);
define _pol_ram		char(2);
define _pol_ano		char(2);

define _pol_suc_1  	char(2);
define _pol_ram_1	char(2);
define _pol_ano_1  	char(2);

define _validar     char(10);
define _validarNo	char(10);

define _cantidad	integer;
define _valor       char(10);

set isolation to dirty read;

-- Secuencia numero de cheques

LET _contador = 0;
LET _tipo     = "**Cheques**";

--{

LET _contador = 0;

foreach
 select no_cheque,
        count(*)
   into _no_cheque,
        _contador
   from chqchmae
  where autorizado = 1
    and pagado     = 1
    and periodo[1,4] matches a_periodo
  group by 1
  order by 1 asc

	if _contador = 1 then
		continue foreach;
	end if

	LET _mensaje = "El cheque #: " || _no_cheque ||
	               " Esta Duplicado " || _contador || " Veces ... ";
	RETURN _mensaje, _tipo, 3 with resume;

end foreach
end procedure
