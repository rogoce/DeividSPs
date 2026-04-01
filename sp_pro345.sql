-- Proyecto de Evaluacion de personas

-- Creado    : 17/01/2011 - Autor: Armando Moreno.

DROP PROCEDURE sp_pro345;
CREATE PROCEDURE sp_pro345(as_no_poliza char(10))
returning varchar(11);

define _no_evaluacion	    varchar(11);	 		   

SET ISOLATION TO DIRTY READ;

let _no_evaluacion = "";

foreach

  SELECT no_evaluacion
	INTO _no_evaluacion
    FROM emievalu
   WHERE no_poliza = as_no_poliza

	exit foreach;

end foreach

if as_no_poliza in('192310') then	--Polizas ingresadas Manualmente, No tienen solicitud. Fany caso 13908
	let _no_evaluacion = "N192310";
end if
if as_no_poliza in('134096') then	--Polizas ingresadas Manualmente, No tienen solicitud. Fany caso 13907
	let _no_evaluacion = "N134096";
end if
if as_no_poliza in('245613') then	--Polizas ingresadas Manualmente, No tienen solicitud. Fany caso 13842
	let _no_evaluacion = "N245613";
end if
if as_no_poliza in('0001303383') then	--Polizas ingresadas Manualmente, No tienen solicitud. Fany caso 13282
	let _no_evaluacion = "N0001303383";
end if
if as_no_poliza in('490321') then	--Polizas ingresadas Manualmente, No tienen solicitud. Fany caso 13604
	let _no_evaluacion = "N490321";
end if
if as_no_poliza in('3269971') then	--Polizas ingresadas Manualmente, No tienen solicitud. Fany caso 16025
	let _no_evaluacion = "N13237";
end if
return trim(_no_evaluacion);

END PROCEDURE
