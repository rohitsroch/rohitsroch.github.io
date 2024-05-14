mkdir ./resized/
for photos in *.jpg *.png *.jpeg; do
    base_name=$(echo "$photos" | cut -d. -f1)
    base_name="${base_name}-card"
    cp "$photos" "./resized/${base_name}.jpg"

    convert -verbose "$photos" -background white -flatten -resize 2000 "./resized/${base_name}_lg.jpg" && 
    convert -verbose "$photos" -background white -flatten -resize 1000 "./resized/${base_name}_md.jpg" && 
    convert -verbose "$photos" -background white -flatten -resize 768 "./resized/${base_name}_sm.jpg" && 
    convert -verbose "$photos" -background white -flatten -resize 575 "./resized/${base_name}_xs.jpg" && 
    convert -verbose "$photos" -background white -flatten -resize 256 "./resized/${base_name}_placehold.jpg" && 
    convert -verbose "$photos" -background white -flatten -resize 535 "./resized/${base_name}_thumb.jpg" && 
    convert -verbose "$photos" -background white -flatten -resize 1070 "./resized/${base_name}_thumb@2x.jpg"; 
done
