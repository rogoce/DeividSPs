-- Niif17
-- Creado    : 18/03/2025 - Autor: Armando Moreno M.
--execute procedure sp_sacniif17_1('2024',12,2,'sac')
--Si hay cambio en el catalogo, se borra tabla sac:cglctaniif17 y se carga con archivo csv suministrado.
--Si hay cambio en la equivalencia, se borra tabla sac:equivniif17 y se carga con archivo csv suministrado.

drop procedure sp_sacniif17_1;
create procedure sp_sacniif17_1(a_ano char(4), a_mes smallint, a_nivel smallint, a_db char(18))
returning   char(6)      as periodo,
            varchar(20)  as tipo_contable,
		    char(12)     as cuenta,
		    char(50)     as nombre,
		    varchar(50)  as cta_niif17,
		    varchar(200) as cta_nombre,
		    varchar(20)  as tipo_acumulacion,
		    dec(16,2)    as importe;

define _mes_char			char(2);
define _periodo			char(6);
define _cuenta				char(12);
define _nombre				char(50);
define _importe			dec(16,2);
define _saldo				dec(16,2);
define _saldo_act			dec(16,2);
define _compania			char(50);
define _valor				smallint;
define _tipo_acumulacion	varchar(20);
define _tipo_contable		varchar(20);
define _cta_niif17		varchar(50);
define _cta_nombre		varchar(200);

set isolation to dirty read;

let a_db = trim(a_db);

select cia_nom
  into _compania
  from sigman02
 where cia_bda_codigo = a_db;

create temp table tmp_saldos(
cuenta		char(12),
nombre		char(50),
debito		dec(16,2),
credito		dec(16,2),
saldo		dec(16,2),
saldo_ant	dec(16,2),
saldo_act	dec(16,2),
referencia	char(20)
) with no log;

if a_mes < 10 then
	let _mes_char = "0" || a_mes;
else
	let _mes_char = a_mes;
end if

let a_nivel = 2;
let _periodo = a_ano || _mes_char;

let _valor = sp_sac42_v2(a_ano, a_mes, a_nivel, a_db);  --Carga tmp_saldos

---BORRAR EL PERIOD A CARGAR*******
delete from sac:balanceniif17
where periodo = _periodo;

foreach
	select t.cuenta,
		   t.nombre,
		   t.saldo,
		   t.saldo_act,
		   n.tipo_contable,
		   n.cta_niif17,
		   n.tipo_acumulacion
	  into _cuenta,
		   _nombre,		
		   _saldo,		
		   _saldo_act,
		   _tipo_contable,
		   _cta_niif17,
		   _tipo_acumulacion
	   from tmp_saldos t, sac:equivniif17 n
	  where t.cuenta = n.cta_niif4
	  order by 1

	let _importe = 0;
	let _cta_nombre = null;
	foreach
		select cta_nombre
		  into _cta_nombre
		  from sac:cglctaniif17
		 where cta_cuenta = _cta_niif17
		exit foreach;
	end foreach
	
	if trim(_tipo_acumulacion) = 'Saldo_Acumulado' then
		let _importe = _saldo_act;
	elif trim(_tipo_acumulacion) = 'Saldo_Periodo' then
		let _importe = _saldo;
	end if
	
	insert into sac:balanceniif17(periodo,tipo_contable,numero_cta_niif4,cta_niif4,numero_cta_niif17,cta_niif17,tipo_acumulacion,importe)
    values(_periodo,_tipo_contable,_cuenta,_nombre,_cta_niif17,_cta_nombre,_tipo_acumulacion,_importe);

	return _periodo,_tipo_contable,_cuenta,_nombre,_cta_niif17,_cta_nombre,_tipo_acumulacion,_importe with resume;

end foreach

drop table tmp_saldos;

end procedure;