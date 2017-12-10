import UIKit

class NoteTableViewCell: UITableViewCell {

    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var textContentLabel: UILabel!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var textTrailingConstraint: NSLayoutConstraint!
    private var offset: CGFloat = 0.0
    private let standardSpacing: CGFloat = 8.0

    override func awakeFromNib() {
        super.awakeFromNib()
        offset = textTrailingConstraint.constant
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(with note: Note, dateFormatter: DateFormatter) {
        textContentLabel?.text = note.text
        if let createdAt = note.createdAt {
            dateLabel.text = dateFormatter.string(from: createdAt as Date)
        } else {
            dateLabel.text = nil
        }

        if let image = note.image {
            userImageView.image = UIImage(data: image as Data)
            textTrailingConstraint.constant = -(userImageView.bounds.width + standardSpacing + offset)
        } else {
            userImageView.image = nil
            textTrailingConstraint.constant = offset
        }

    }

}
