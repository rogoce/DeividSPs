-- Procedimiento que retorna el trimestre de reaseguro dado el periodo
 
-- Creado     :	12/11/2009 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rea002a;		

create procedure "informix".sp_rea002a(a_periodo char(7), a_tipo smallint default 1)
returning varchar(50);



define _per_ano		char(9);
define _trim		smallint;
define _descr       char(3);
define _per1        char(7);
define _per3        char(7);
define _mes         smallint;
define _nombre      char(10);
define _des_final   varchar(50);

let _descr     = "";
let _nombre    = "";
let _des_final = "";

select ano,
       trimestre,
	   descripcion,
	   periodo1,
	   periodo3
  into _per_ano,
       _trim,
	   _descr,
	   _per1,
	   _per3
  from reatrim
 where periodo3 = a_periodo
   and tipo     = a_tipo;

let _mes    = _per1[6,7];
let _nombre = sp_sac18(_mes);

let _des_final = _descr || " TRIMESTRE (" || _nombre; 

let _mes    = _per3[6,7];
let _nombre = sp_sac18(_mes);
let _des_final = trim(_des_final) || "-" || trim(_nombre); 
let _des_final = trim(_des_final) || " " || a_periodo[1,4] || ")";

if _per_ano is not null then
	return _des_final;
end if

end procedure
