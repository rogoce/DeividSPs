-- Procedimiento que carga el archivo de renovaciones para la Cartera Banisi.
-- creado    : 05/10/2012 - Autor: Roman Gordon--
-- sis v.2.0 - deivid, s.a.
-- execute procedure sp_pro371_test('2020-10')

drop procedure sp_pro371_test;
create procedure "informix".sp_pro371_test(a_periodo char(7))
returning   integer,
			char(100);   -- _error

define _error_desc		varchar(100);
define _no_documento	char(20);
define _no_poliza		char(10);
define _periodo			char(7);
define _mes				char(2);
define _error_isam		integer;
define _error			integer;

begin

on exception set _error,_error_isam,_error_desc
 	return _error,_error_desc;
end exception

--set debug file to "sp_pro371.trc";
--trace on;

set isolation to dirty read;

let _mes = a_periodo[6,7];

foreach	
select --distinct("'"||trim(emi.no_documento)||"',")
           emi.no_poliza,
		   emi.no_documento,
		   emi.periodo   --, emi.vigencia_inic, emi.nueva_renov
	  into _no_poliza,
		   _no_documento,
		   _periodo           
		  from emipomae emi
		 inner join emipoagt agt on emi.no_poliza = agt.no_poliza   and agt.cod_agente =  '02904' --  '00035' --
		 left join emirenduc duc on duc.no_documento = emi.no_documento  and duc.periodo[1,4] <> '2022'
		-- inner join prdforemelm ext on ext.cod_agente = agt.cod_agente
		 where emi.cod_ramo in (select cod_ramo from prdramo where ramo_sis = 1)
		 --  and emi.no_poliza = a_poliza
--and emi.periodo = '2021-11'
	and emi.cod_grupo in ('1122','77850','77960')
		   and emi.estatus_poliza = 1 -- and year(emi.vigencia_final) not in  (2023)
		   and emi.nueva_renov  in ( 'R*','N')  ---and emi.periodo = '2022-11'
     and   emi.no_documento in (  --= '0221-01806-90'     
"0219-30036-01",
"0219-30464-01",
"0221-01741-90",
"0221-01743-90",
"0221-01744-90",
"0221-01745-90",
"0221-01746-90",
"0221-01747-90",
"0221-01748-90",
"0221-01749-90",
"0221-01750-90",
"0221-01751-90",
"0221-01752-90",
"0221-01753-90",
"0221-01754-90",
"0221-01755-90",
"0221-01756-90",
"0221-01757-90",
"0221-01758-90",
"0221-01759-90",
"0221-01760-90",
"0221-01761-90",
"0221-01762-90",
"0221-01763-90",
"0221-01764-90",
"0221-01765-90",
"0221-01766-90",
"0221-01767-90",
"0221-01769-90",
"0221-01770-90",
"0221-01771-90",
"0221-01772-90",
"0221-01773-90",
"0221-01774-90",
"0221-01775-90",
"0221-01776-90",
"0221-01777-90",
"0221-01778-90",
"0221-01779-90",
"0221-01780-90",
"0221-01781-90",
"0221-01782-90",
"0221-01783-90",
"0221-01784-90",
"0221-01785-90",
"0221-01786-90",
"0221-01787-90",
"0221-01788-90",
"0221-01789-90",
"0221-01790-90",
"0221-01791-90",
"0221-01793-90",
"0221-01794-90",
"0221-01795-90",
"0221-01797-90",
"0221-01798-90",
"0221-01799-90",
"0221-01800-90",
"0221-01801-90",
"0221-01802-90",
"0221-01803-90",
"0221-01806-90")
		order by 1	

	call sp_pro371_11(_no_poliza) returning _error, _error_desc;
{
	if _error = 0 then
		update emirenduc
		   set periodo = '2022-' || _mes
		 where no_documento = _no_documento
		   and periodo = a_periodo;
 
	end if
	}
end foreach
end

return 0,'Inserción Exitosa del Registro';
end procedure ;
                
