-- Para encontrar la vigencia vigente real de la poliza  
-- Creado    : 14/12/2017 - Autor: Henry Giron 
-- SIS v.2.0 - DEIVID, S.A. 

DROP PROCEDURE sp_rec14_vig_real;
CREATE PROCEDURE "informix".sp_rec14_vig_real( a_no_poliza CHAR(10), a_periodo1 CHAR(7), a_periodo2 CHAR(7)) 
RETURNING CHAR(7) as periodo1r,
          CHAR(7) as periodo2r;

DEFINE _vigencia_inic  DATE;
DEFINE _vigencia_final DATE;
DEFINE _vigencia_final_anual DATE;
DEFINE _periodo1,_periodo2	   CHAR(7);
DEFINE _periodo1r,_periodo2r   CHAR(7);
DEFINE _cant_ano, i integer;
DEFINE _mes1,_mes2,_anio1,_anio2, _anior integer;
DEFINE _mes1s,_mes2s, _mesxs   CHAR(2);

drop table if exists tmp_vigencia2;
create temp table tmp_vigencia2(
periodo1 CHAR(7),   
periodo2 CHAR(7),
vigencia_inic DATE,
vigencia_final DATE,
seleccionado smallint) with no log;
SET ISOLATION TO DIRTY READ;

FOREACH 
 SELECT	vigencia_inic, vigencia_final 
   INTO _vigencia_inic, _vigencia_final 
   FROM	emipomae 
  WHERE no_poliza = a_no_poliza   
     -- AND periodo = a_periodo1 
	AND actualizado = 1  
  ORDER BY vigencia_final DESC  
   EXIT FOREACH;  
END FOREACH  

call sp_sis39(_vigencia_inic) returning _periodo1; 
call sp_sis39(_vigencia_final) returning _periodo2; 

let _vigencia_final_anual = _vigencia_inic + 1 units year;

let _cant_ano = _periodo2[1,4] - _periodo1[1,4]; 
let _mes1 = _periodo1[6,7];
let _anior = a_periodo1[1,4];

--let _mes2 = _periodo2[6,7];
if _mes1 = 1 then
	let _mes2 = '12';
else
    let _mes2 = _periodo1[6,7]-1;	
end if
--let _mes2 = _periodo2[6,7];
let _mesxs = "00";
let _anio1 = _periodo1[1,4];
--let _anio2 = _periodo2[1,4];
if _anior < _anio1 then 
   let _anio1 = _anior;
   let _cant_ano = _periodo2[1,4] - _anio1; 
end if

for i = 1 to _cant_ano + 1 		
	if _mes1 < 10 then
		let _mes1s = '0'||_mes1;
	else
		let _mes1s = _mes1;
	end if
	if _mes2 < 10 then
		let _mes2s = '0'||_mes2;
	else
		let _mes2s = _mes2;
	end if
	if _mes2s = '12' then
		let _anio2 = _anio1;
	else
		let _anio2 = _anio1 + 1;
	end if
	let _periodo1r = _anio1||'-'||_mes1s; 
	let _periodo2r = _anio2||'-'||_mes2s; 
	
	insert into tmp_vigencia2(periodo1, periodo2, vigencia_inic, vigencia_final, seleccionado) 
	values(_periodo1r, _periodo2r, _vigencia_inic, _vigencia_final_anual, 0); 	
	
	let _anio1 = _anio1 + 1;

    let	_vigencia_inic = _vigencia_inic + 1 units year;
    let	_vigencia_final_anual = _vigencia_final_anual + 1 units year;
	
	let _mesxs = _mes1s;
	
	if _mes1s = '01' then
		let _mesxs = '13';
		--let _anio1 = _anio1 - 1;
	end if
	if _mes2s = '12' then
		let _mes2s = '00';
	end if	
	let _mes1 = _mes2s + 1;
	let _mes2 = _mesxs - 1;
end for

-- Cambio porque no estaba tomando los años completos según el periodo Amado 12-03-2024
update tmp_vigencia2
   set seleccionado = 1
 where periodo1[1,4] >= a_periodo1[1,4]
   and periodo2[1,4] <= a_periodo2[1,4];

{update tmp_vigencia2
   set seleccionado = 1
 where periodo1[1,4]||periodo1[6,7] >= a_periodo1[1,4]||a_periodo1[6,7]
and periodo2[1,4]||periodo2[6,7] <= a_periodo2[1,4]||a_periodo2[6,7];
}
{select distinct periodo1, periodo2
  into _periodo1, _periodo2
  from tmp_vigencia2
 where periodo1[1,4]||periodo1[6,7] <= a_periodo1[1,4]||a_periodo1[6,7]
and periodo2[1,4]||periodo2[6,7] >= a_periodo1[1,4]||a_periodo1[6,7];

if _periodo1 is null then		
	set debug file to "sp_rec14_vig_real.trc"; 
	trace on;	
	let a_no_poliza = a_no_poliza;
	let a_periodo1 = a_periodo1;	

	return '1','1';	
end if	}
RETURN _periodo1, _periodo2;


END PROCEDURE;