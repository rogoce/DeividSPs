   --Procedimiento que devuelve el pin de ciertas condiciones para data enviada a panama asitencia SOBAT
   --  Armando Moreno M. 10/08/2017
   
   DROP procedure sp_super27;
   CREATE procedure sp_super27(a_no_poliza char(10), a_no_unidad char(5))
   RETURNING char(4);
   
   DEFINE _cod_producto  char(5);
   define _no_motor      char(30);
   define _ano_auto      smallint;
   define _anos          smallint;
   define _vigencia_inic date;
   define _pin   		 char(4);
   
SET ISOLATION TO DIRTY READ;
let _pin = '';
--Set Debug File To "sp_super27.trc";
--trace on;
--Automovil, busqueda de pin de acuerdo al producto y años de automóvil

select vigencia_inic
  into _vigencia_inic
  from emipomae
 where no_poliza = a_no_poliza;

select cod_producto
  into _cod_producto
  from emipouni
 where no_poliza = a_no_poliza
   and no_unidad = a_no_unidad;
   
if _cod_producto in ('04980','04981','05971','06132','06134','06138','06140','07223','07224','07225','07230','07234','07286',
                     '04979','05055','05771','05772','05773','05774','05775','05776','05777','05778','05779','05781','05782',
                     '05783','05784','06669','05769','07229','07285') then
	
	if _vigencia_inic <= '28/02/2022' then
		if _cod_producto = '04980' then
			return 'STE1';
		else
			return 'STE';
		end if		
	else
	
		select no_motor
		  into _no_motor
		  from emiauto
		 where no_poliza = a_no_poliza
		   and no_unidad = a_no_unidad;
		   
		select ano_auto
		  into _ano_auto
		  from emivehic
		 where no_motor = _no_motor;

		let _anos = year(current) - _ano_auto;

		if _anos is null then
			let _anos = 0;
		end if

		if _anos < 0 then
			let _anos = 0;
		end if
		
		if _anos >= 0 and _anos <= 10 then
			return 'ST';
		elif _anos >= 11 and _anos <= 19 then
			return 'S1T';
		else
			return 'S2T';
		end if
	end if
else	
	return '';
end if


END PROCEDURE;